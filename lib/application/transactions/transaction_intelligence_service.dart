import '../../domain/ai/ai_category_fallback.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/services/category_learning_service.dart';
import 'local_transaction_parser.dart';

class TransactionIntelligenceService {
  TransactionIntelligenceService({
    required this.categoryLearning,
    required this.aiFallback,
    this.aiTriggerConfidence = 0.85,
  });

  final CategoryLearningService categoryLearning;
  final AiCategoryFallback aiFallback;
  final double aiTriggerConfidence;

  Future<List<IntelligentTransaction>> process({
    required String userId,
    required String input,
  }) async {
    final localResults = LocalTransactionParser().parse(input);
    final results = <IntelligentTransaction>[];
    List<String>? availableCategoryIds;

    for (final local in localResults) {
      final learnedCategory = await categoryLearning.resolve(
        userId: userId,
        text: local.description,
        fallbackCategoryId: local.categoryId,
      );

      final resolvedCategory = learnedCategory ?? local.categoryId;
      final localIsConfident = local.confidence >= aiTriggerConfidence &&
          resolvedCategory != 'lainnya';

      if (localIsConfident) {
        results.add(IntelligentTransaction.fromLocal(local, resolvedCategory));
        continue;
      }

      availableCategoryIds ??= (await categoryLearning.repository.getCategories())
          .map((category) => category.id).toList();
      final suggestion = await aiFallback.resolve(
        AiCategoryRequest(
          userId: userId,
          originalText: input,
          description: local.description,
          type: local.type == ParsedTransactionType.income
              ? TransactionType.income
              : TransactionType.expense,
          amount: local.amount,
          localCategoryId: resolvedCategory,
          availableCategoryIds: availableCategoryIds,
        ),
      );

      if (suggestion == null) {
        results.add(
          IntelligentTransaction.fromLocal(
            local,
            resolvedCategory,
            processedBy: ProcessedBy.manual,
          ),
        );
      } else {
        results.add(
          IntelligentTransaction.fromLocal(
            local,
            suggestion.categoryId,
            processedBy: ProcessedBy.aiFallback,
            confidence: suggestion.confidence,
          ),
        );
      }
    }

    return results;
  }
}

class IntelligentTransaction {
  const IntelligentTransaction({
    required this.amount,
    required this.description,
    required this.type,
    required this.categoryId,
    required this.processedBy,
    required this.confidence,
  });

  final double amount;
  final String description;
  final ParsedTransactionType type;
  final String categoryId;
  final ProcessedBy processedBy;
  final double confidence;

  factory IntelligentTransaction.fromLocal(
    ParsedTransaction source,
    String categoryId, {
    ProcessedBy processedBy = ProcessedBy.localParser,
    double? confidence,
  }) {
    return IntelligentTransaction(
      amount: source.amount,
      description: source.description,
      type: source.type,
      categoryId: categoryId,
      processedBy: processedBy,
      confidence: confidence ?? source.confidence,
    );
  }
}
