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

/// One catalog: persisted legacy name, public display label and transaction type.
/// Keep stored names compatible while the UI uses the established richer labels.
const systemCategoryDefaults = <String, (String, String, String)>{
  'gaji': ('Gaji', 'Gaji dan upah', 'income'),
  'bonus': ('Bonus', 'Bonus dan pendapatan lain', 'income'),
  'makanan': ('Makanan', 'Makanan dan minuman', 'expense'),
  'belanja_dapur': ('Belanja Dapur', 'Kebutuhan rumah tangga', 'expense'),
  'transportasi': ('Transportasi', 'Transportasi', 'expense'),
  'tagihan': ('Tagihan', 'Tagihan', 'expense'),
  'kesehatan': ('Kesehatan', 'Kesehatan', 'expense'),
  'hiburan': ('Hiburan', 'Hiburan', 'expense'),
  'lainnya': ('Lainnya', 'Lainnya', 'expense'),
};
