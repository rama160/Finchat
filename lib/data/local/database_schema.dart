import 'package:sqflite/sqflite.dart';

import '../../domain/entities/category_entity.dart';

class FinChatDatabaseSchema {
  static const databaseName = 'finchat.db';
  static const version = 1;

  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT,
        display_name TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        is_system INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        category_id TEXT NOT NULL,
        transaction_date INTEGER NOT NULL,
        transaction_time INTEGER,
        input_source TEXT NOT NULL,
        processed_by TEXT NOT NULL,
        confidence REAL NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        sync_status TEXT NOT NULL DEFAULT 'local',
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE category_mappings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        normalized_keyword TEXT NOT NULL,
        category_id TEXT NOT NULL,
        source TEXT NOT NULL,
        confidence REAL NOT NULL,
        usage_count INTEGER NOT NULL DEFAULT 1,
        last_used_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(user_id, normalized_keyword),
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE category_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        transaction_id TEXT,
        keyword TEXT NOT NULL,
        previous_category_id TEXT,
        new_category_id TEXT NOT NULL,
        source TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(transaction_id) REFERENCES transactions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_transactions_user_date ON transactions(user_id, transaction_date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_user_type ON transactions(user_id, type)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_user_category ON transactions(user_id, category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_category_mapping_user_keyword ON category_mappings(user_id, normalized_keyword)',
    );
    await db.execute(
      'CREATE INDEX idx_category_history_user_created ON category_history(user_id, created_at)',
    );

    await _seedCategories(db);
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2 && newVersion >= 2) {
      // Reserved for the next schema migration. Never destructively recreate user data.
    }
  }

  static Future<void> _seedCategories(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final entry in systemCategoryDefaults.entries) {
      await db.insert('categories', {
        'id': entry.key,
        'name': entry.value.$1,
        'type': entry.value.$3,
        'is_system': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}
