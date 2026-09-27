import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/transactions/transaction_intelligence_service.dart';
import 'package:finchat/domain/ai/ai_category_fallback.dart';
import 'package:finchat/domain/entities/category_mapping.dart';
import 'package:finchat/domain/entities/category_entity.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';
import 'package:finchat/domain/repositories/category_repository.dart';
import 'package:finchat/domain/services/category_learning_service.dart';

class FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryEntity>> getCategories({String? type}) async => const [];

  @override
  Future<CategoryEntity?> getById(String id) async => null;

  @override
  Future<CategoryMapping?> findMapping(String userId, String keyword) async => null;

  @override
  Future<void> learnMapping({
    required String userId,
    required String keyword,
    required String categoryId,
    String source = 'user_correction',
    double confidence = 1.0,
  }) async {}

  @override
  Future<List<CategoryMapping>> getMappings(String userId) async => const [];
}

class FakeProvider implements AiCategoryProvider {
  FakeProvider(this.suggestion);

  final AiCategorySuggestion? suggestion;
  int calls = 0;

  @override
  Future<AiCategorySuggestion?> suggestCategory(AiCategoryRequest request) async {
    calls++;
    return suggestion;
  }
}

void main() {
  test('uses AI only when local category is unresolved', () async {
    final provider = FakeProvider(
      const AiCategorySuggestion(categoryId: 'lainnya', confidence: 0.9),
    );
    final service = TransactionIntelligenceService(
      categoryLearning: CategoryLearningService(FakeCategoryRepository()),
      aiFallback: AiCategoryFallback(
        provider: provider,
        categoryExists: (id) async => id == 'lainnya',
      ),
    );

    final result = await service.process(
      userId: 'u1',
      input: 'Transfer 50k',
    );

    expect(provider.calls, 1);
    expect(result.single.amount, 50000);
    expect(result.single.categoryId, 'lainnya');
    expect(result.single.processedBy, ProcessedBy.aiFallback);
  });

  test('does not call AI for a confidently locally categorized transaction', () async {
    final provider = FakeProvider(
      const AiCategorySuggestion(categoryId: 'tagihan', confidence: 0.99),
    );
    final service = TransactionIntelligenceService(
      categoryLearning: CategoryLearningService(FakeCategoryRepository()),
      aiFallback: AiCategoryFallback(
        provider: provider,
        categoryExists: (_) async => true,
      ),
    );

    final result = await service.process(
      userId: 'u1',
      input: 'Beli nasi 25 rb',
    );

    expect(provider.calls, 0);
    expect(result.single.categoryId, 'makanan');
    expect(result.single.processedBy, ProcessedBy.localParser);
  });
}
