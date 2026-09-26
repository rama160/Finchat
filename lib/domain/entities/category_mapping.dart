class CategoryMapping {
  const CategoryMapping({
    required this.id,
    required this.userId,
    required this.normalizedKeyword,
    required this.categoryId,
    required this.source,
    required this.confidence,
    required this.usageCount,
    required this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String normalizedKeyword;
  final String categoryId;
  final String source;
  final double confidence;
  final int usageCount;
  final DateTime lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
