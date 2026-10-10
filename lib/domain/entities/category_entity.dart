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

/// Shared catalog for database seeding, missing legacy categories and UI labels.
const systemCategoryDefaults = <String, (String, String)>{
  'gaji': ('Gaji dan upah', 'income'),
  'bonus': ('Bonus dan pendapatan lain', 'income'),
  'makanan': ('Makanan dan minuman', 'expense'),
  'belanja_dapur': ('Kebutuhan rumah tangga', 'expense'),
  'transportasi': ('Transportasi', 'expense'),
  'tagihan': ('Tagihan', 'expense'),
  'kesehatan': ('Kesehatan', 'expense'),
  'hiburan': ('Hiburan', 'expense'),
  'lainnya': ('Lainnya', 'expense'),
};
