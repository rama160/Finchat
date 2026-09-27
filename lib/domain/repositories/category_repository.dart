import '../entities/category_entity.dart';
import '../entities/category_mapping.dart';

abstract interface class CategoryRepository {
  Future<List<CategoryEntity>> getCategories({String? type});
  Future<CategoryEntity?> getById(String id);
  Future<CategoryMapping?> findMapping(String userId, String keyword);
  Future<void> learnMapping({
    required String userId,
    required String keyword,
    required String categoryId,
    String source = 'user_correction',
    double confidence = 1.0,
  });
  Future<List<CategoryMapping>> getMappings(String userId);
}
