import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/category_mapping.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/services/category_learning_service.dart';
import '../local/finchat_database.dart';

class SqliteCategoryRepository implements CategoryRepository {
  SqliteCategoryRepository(this.database);

  final FinChatDatabase database;

  Future<CategoryEntity> ensureCategory(String name, String type) async {
    final trimmed = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty || trimmed.length > 50 || !['income', 'expense'].contains(type)) {
      throw ArgumentError('Kategori harus berisi 1–50 karakter.');
    }
    final db = await database.database;
    return db.transaction((txn) async {
      final rows = await txn.query('categories', where: 'type = ?', whereArgs: [type]);
      for (final row in rows) {
        if ((row['name'] as String).trim().toLowerCase() == trimmed.toLowerCase()) return _categoryFromRow(row);
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = 'custom_${type}_${base64Url.encode(utf8.encode(trimmed.toLowerCase())).replaceAll('=', '')}';
      final row = <String, Object?>{'id': id, 'name': trimmed, 'type': type,
        'is_system': 0, 'created_at': now, 'updated_at': now};
      await txn.insert('categories', row);
      return _categoryFromRow(row);
    });
  }

  @override
  Future<List<CategoryEntity>> getCategories({String? type}) async {
    final db = await database.database;
    final rows = await db.query(
      'categories',
      where: type == null ? null : 'type = ?',
      whereArgs: type == null ? null : [type],
      orderBy: 'is_system DESC, name ASC',
    );
    return rows.map(_categoryFromRow).toList();
  }

  @override
  Future<CategoryEntity?> getById(String id) async {
    final db = await database.database;
    final rows = await db.query('categories', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : _categoryFromRow(rows.first);
  }

  @override
  Future<CategoryMapping?> findMapping(String userId, String keyword) async {
    final db = await database.database;
    final normalized = CategoryLearningService.normalize(keyword);
    if (normalized.isEmpty) return null;
    final rows = await db.query(
      'category_mappings',
      where: 'user_id = ? AND normalized_keyword = ?',
      whereArgs: [userId, normalized],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mappingFromRow(rows.first);
  }

  @override
  Future<void> learnMapping({
    required String userId,
    required String keyword,
    required String categoryId,
    String source = 'user_correction',
    double confidence = 1.0,
  }) async {
    final db = await database.database;
    final normalized = CategoryLearningService.normalize(keyword);
    if (normalized.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await findMapping(userId, normalized);
    final id = existing?.id ?? '${userId}_$normalized';
    final usage = (existing?.usageCount ?? 0) + 1;

    await db.transaction((txn) async {
      await txn.insert(
        'category_mappings',
        {
          'id': id,
          'user_id': userId,
          'normalized_keyword': normalized,
          'category_id': categoryId,
          'source': source,
          'confidence': confidence,
          'usage_count': usage,
          'last_used_at': now,
          'created_at': existing?.createdAt.millisecondsSinceEpoch ?? now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert('category_history', {
        'id': '${id}_${now}_$usage',
        'user_id': userId,
        'transaction_id': null,
        'keyword': normalized,
        'previous_category_id': existing?.categoryId,
        'new_category_id': categoryId,
        'source': source,
        'created_at': now,
      });
    });
  }

  @override
  Future<List<CategoryMapping>> getMappings(String userId) async {
    final db = await database.database;
    final rows = await db.query(
      'category_mappings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'usage_count DESC, last_used_at DESC',
    );
    return rows.map(_mappingFromRow).toList();
  }

  CategoryEntity _categoryFromRow(Map<String, Object?> row) => CategoryEntity(
        id: row['id']! as String,
        name: row['name']! as String,
        type: row['type']! as String,
        isSystem: (row['is_system']! as int) == 1,
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
      );

  CategoryMapping _mappingFromRow(Map<String, Object?> row) => CategoryMapping(
        id: row['id']! as String,
        userId: row['user_id']! as String,
        normalizedKeyword: row['normalized_keyword']! as String,
        categoryId: row['category_id']! as String,
        source: row['source']! as String,
        confidence: (row['confidence']! as num).toDouble(),
        usageCount: row['usage_count']! as int,
        lastUsedAt: DateTime.fromMillisecondsSinceEpoch(row['last_used_at']! as int),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at']! as int),
      );

  DateTime? _date(Object? value) => value == null ? null : DateTime.fromMillisecondsSinceEpoch(value as int);
}
