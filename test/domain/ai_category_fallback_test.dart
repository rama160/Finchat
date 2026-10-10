import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/domain/ai/ai_category_fallback.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';

class FakeAiProvider implements AiCategoryProvider {
  FakeAiProvider(this.result);

  final AiCategorySuggestion? result;
  int calls = 0;

  @override
  Future<AiCategorySuggestion?> suggestCategory(
    AiCategoryRequest request,
  ) async {
    calls++;
    return result;
  }
}

class ThrowingProvider implements AiCategoryProvider {
  @override
  Future<AiCategorySuggestion?> suggestCategory(
    AiCategoryRequest request,
  ) async => throw StateError('offline');
}

void main() {
  test(
    'provider errors and non-finite confidence leave local capture available',
    () async {
      const request = AiCategoryRequest(
        userId: 'u',
        originalText: 'kopi 20rb',
        description: 'kopi',
        type: TransactionType.expense,
        amount: 20000,
        localCategoryId: 'lainnya',
      );
      final failed = AiCategoryFallback(
        provider: ThrowingProvider(),
        categoryExists: (_) async => true,
      );
      expect(await failed.resolve(request), isNull);
      final invalid = AiCategoryFallback(
        provider: FakeAiProvider(
          const AiCategorySuggestion(
            categoryId: 'makanan',
            confidence: double.nan,
          ),
        ),
        categoryExists: (_) async => true,
      );
      expect(await invalid.resolve(request), isNull);
    },
  );
  test('accepts a valid category suggestion above threshold', () async {
    final provider = FakeAiProvider(
      const AiCategorySuggestion(categoryId: 'makanan', confidence: 0.9),
    );
    final fallback = AiCategoryFallback(
      provider: provider,
      categoryExists: (id) async => id == 'makanan',
    );

    final result = await fallback.resolve(
      const AiCategoryRequest(
        userId: 'u1',
        originalText: 'makan di warung 30k',
        description: 'makan di warung',
        type: TransactionType.expense,
        amount: 30000,
        localCategoryId: 'lainnya',
      ),
    );

    expect(result?.categoryId, 'makanan');
  });

  test('rejects unknown category', () async {
    final provider = FakeAiProvider(
      const AiCategorySuggestion(categoryId: 'invented', confidence: 0.99),
    );
    final fallback = AiCategoryFallback(
      provider: provider,
      categoryExists: (_) async => false,
    );

    final result = await fallback.resolve(
      const AiCategoryRequest(
        userId: 'u1',
        originalText: 'transaksi 30k',
        description: 'transaksi',
        type: TransactionType.expense,
        amount: 30000,
        localCategoryId: 'lainnya',
      ),
    );

    expect(result, isNull);
  });

  test('rejects low confidence suggestion', () async {
    final provider = FakeAiProvider(
      const AiCategorySuggestion(categoryId: 'makanan', confidence: 0.5),
    );
    final fallback = AiCategoryFallback(
      provider: provider,
      categoryExists: (_) async => true,
    );

    final result = await fallback.resolve(
      const AiCategoryRequest(
        userId: 'u1',
        originalText: 'transaksi 30k',
        description: 'transaksi',
        type: TransactionType.expense,
        amount: 30000,
        localCategoryId: 'lainnya',
      ),
    );

    expect(result, isNull);
  });
}
