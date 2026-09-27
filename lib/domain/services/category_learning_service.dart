import '../entities/category_mapping.dart';
import '../repositories/category_repository.dart';

class CategoryLearningService {
  CategoryLearningService(this.repository);

  final CategoryRepository repository;

  Future<String?> resolve({
    required String userId,
    required String text,
    String? fallbackCategoryId,
  }) async {
    final normalized = normalize(text);
    if (normalized.isEmpty) return fallbackCategoryId;

    final tokens = <String>{normalized, ..._tokens(normalized)};
    CategoryMapping? best;
    for (final token in tokens) {
      final mapping = await repository.findMapping(userId, token);
      if (mapping == null) continue;
      if (best == null || _score(mapping, token) > _score(best, best.normalizedKeyword)) {
        best = mapping;
      }
    }
    return best?.categoryId ?? fallbackCategoryId;
  }

  Future<void> recordCorrection({
    required String userId,
    required String text,
    required String categoryId,
  }) async {
    final normalized = normalize(text);
    if (normalized.isEmpty) return;
    await repository.learnMapping(
      userId: userId,
      keyword: normalized,
      categoryId: categoryId,
      source: 'user_correction',
      confidence: 1.0,
    );
  }

  static String normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Iterable<String> _tokens(String value) sync* {
    final parts = value.split(' ');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].length >= 3) yield parts[i];
    }
  }

  double _score(CategoryMapping mapping, String matchedKeyword) {
    var score = mapping.confidence + (mapping.usageCount * 0.01);
    if (matchedKeyword == mapping.normalizedKeyword) score += 1.0;
    if (mapping.source == 'user_correction') score += 2.0;
    return score;
  }
}
