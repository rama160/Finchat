import '../entities/transaction_entity.dart';

class AiCategoryRequest {
  const AiCategoryRequest({
    required this.userId,
    required this.originalText,
    required this.description,
    required this.type,
    required this.amount,
    required this.localCategoryId,
    this.availableCategoryIds = const [],
  });

  final String userId;
  final String originalText;
  final String description;
  final TransactionType type;
  final double amount;
  final String localCategoryId;
  final List<String> availableCategoryIds;
}

class AiCategorySuggestion {
  const AiCategorySuggestion({
    required this.categoryId,
    required this.confidence,
  });

  final String categoryId;
  final double confidence;
}

abstract interface class AiCategoryProvider {
  Future<AiCategorySuggestion?> suggestCategory(AiCategoryRequest request);
}

class AiCategoryFallback {
  AiCategoryFallback({
    required this.provider,
    required this.categoryExists,
    this.minimumConfidence = 0.75,
  });

  final AiCategoryProvider provider;
  final Future<bool> Function(String categoryId) categoryExists;
  final double minimumConfidence;

  Future<AiCategorySuggestion?> resolve(AiCategoryRequest request) async {
    final suggestion = await provider.suggestCategory(request);
    if (suggestion == null) return null;
    if (suggestion.categoryId.trim().isEmpty) return null;
    if (suggestion.confidence < minimumConfidence || suggestion.confidence > 1) {
      return null;
    }
    if (!await categoryExists(suggestion.categoryId)) return null;
    return suggestion;
  }
}
