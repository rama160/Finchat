import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/transactions/transaction_intelligence_service.dart';
import 'package:finchat/domain/ai/ai_category_fallback.dart';
import 'package:finchat/domain/entities/category_mapping.dart';
import 'package:finchat/domain/entities/category_entity.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';
import 'package:finchat/domain/repositories/category_repository.dart';
import 'package:finchat/domain/services/category_learning_service.dart';
import 'package:finchat/application/ocr/receipt_transaction_parser.dart';
import 'package:finchat/application/transactions/local_transaction_parser.dart';
import 'package:finchat/domain/parsing/voice_transaction_normalizer.dart';

class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository({this.mapping});
  final CategoryMapping? mapping;
  int mappingReads = 0;
  @override
  Future<List<CategoryEntity>> getCategories({String? type}) async => const [];

  @override
  Future<CategoryEntity?> getById(String id) async => null;

  @override
  Future<CategoryMapping?> findMapping(String userId, String keyword) async => mapping?.userId == userId && mapping?.normalizedKeyword == keyword ? mapping : null;

  @override
  Future<void> learnMapping({
    required String userId,
    required String keyword,
    required String categoryId,
    String source = 'user_correction',
    double confidence = 1.0,
  }) async {}

  @override
  Future<List<CategoryMapping>> getMappings(String userId) async { mappingReads++; return [if (mapping != null && mapping!.userId == userId) mapping!]; }
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
  test('explicit user learning wins over cloud fallback even for low confidence and other category', () async {
    final at = DateTime(2026, 10, 6);
    final categories = FakeCategoryRepository(mapping: CategoryMapping(id: 'learned', userId: 'u1', normalizedKeyword: 'transfer', categoryId: 'lainnya', source: 'user_correction', confidence: 1, usageCount: 1, lastUsedAt: at, createdAt: at, updatedAt: at));
    final provider = FakeProvider(const AiCategorySuggestion(categoryId: 'tagihan', confidence: .99));
    final service = TransactionIntelligenceService(categoryLearning: CategoryLearningService(categories), aiFallback: AiCategoryFallback(provider: provider, categoryExists: (_) async => true));
    final result = await service.processParsed(userId: 'u1', localResults: [ParsedTransaction(amount: 50000, description: 'transfer', type: ParsedTransactionType.expense, categoryId: 'lainnya', confidence: .2)], allowAi: true);
    expect(result.single.categoryId, 'lainnya'); expect(result.single.amount, 50000);
    expect(provider.calls, 0); expect(result.single.processedBy, ProcessedBy.localParser);
  });
  test('one spoken multi transaction input remains local with numeric and word prices', () async {
    final provider = FakeProvider(null);
    final categories = FakeCategoryRepository();
    final service = TransactionIntelligenceService(categoryLearning: CategoryLearningService(categories),
      aiFallback: AiCategoryFallback(provider: provider, categoryExists: (_) async => true));
    final input = normalizeVoiceTransactions('nasi sepuluh ribu dan bensin 50000 lalu parkir dua rebu');
    final result = await service.process(userId: 'u1', input: input, allowAi: false);
    expect(result.map((r) => r.amount), [10000, 50000, 2000]);
    expect(result.map((r) => r.description), ['nasi', 'bensin', 'parkir']);
    expect(provider.calls, 0);
    expect(categories.mappingReads, 1);
    expect(normalizeVoiceTransactions('berapa pengeluaran tahun 2026?'), 'berapa pengeluaran tahun 2026?');
  });
  test('receipt batch preserves product names/amounts and reads mappings once', () async {
    final provider = FakeProvider(null);
    final categories = FakeCategoryRepository();
    final service = TransactionIntelligenceService(categoryLearning: CategoryLearningService(categories),
      aiFallback: AiCategoryFallback(provider: provider, categoryExists: (_) async => true));
    final parsed = const ReceiptTransactionParser().parse('PIA SARI RASA COKLAT\n1 PAK x 20,000 = 20,000\nDAIA POWDER DET BAG\n1 PCS x 18,800 = 18,800\nSLEEK BABY CLEANSER\n1 PCS x 30,259 = 30,259\nTunai = 70,000\nKembali = 941');
    final result = await service.processParsed(userId: 'u1', localResults: parsed);
    expect(result, hasLength(3));
    expect(result.map((r) => r.description), parsed.map((r) => r.description));
    expect(result.fold<double>(0, (sum, r) => sum + r.amount), 69059);
    expect(provider.calls, 0);
    expect(categories.mappingReads, 1);
    final large = List.generate(40, (i) => ParsedTransaction(amount: 10000, description: 'Produk $i', type: ParsedTransactionType.expense, categoryId: 'lainnya', confidence: .9));
    expect(await service.processParsed(userId: 'u1', localResults: large), hasLength(40));
    expect(categories.mappingReads, 2);
  });
  test('production capture never waits for AI even for unknown multi items', () async {
    final provider = FakeProvider(null);
    final service = TransactionIntelligenceService(
      categoryLearning: CategoryLearningService(FakeCategoryRepository()),
      aiFallback: AiCategoryFallback(provider: provider, categoryExists: (_) async => true),
    );
    final results = await service.process(userId: 'u1', input: 'nasi 10 ribu, baju 150 ribu, mobil 3.5 juta', allowAi: false);
    expect(results.length, 3);
    expect(results.first.amount, 10000);
    expect(results.first.categoryId, 'makanan');
    expect(provider.calls, 0);
    expect(results.every((item) => item.processedBy == ProcessedBy.localParser), isTrue);
    final spoken = await service.process(userId: 'u1', input: 'nasi sepuluh ribu', allowAi: false);
    expect(spoken.single.amount, 10000);
    expect(provider.calls, 0);
  });

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
