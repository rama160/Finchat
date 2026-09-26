class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    this.isSystem = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String type;
  final bool isSystem;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
