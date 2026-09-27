import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'database_schema.dart';

class FinChatDatabase {
  FinChatDatabase({DatabaseFactory? factory, this.databasePath})
      : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  final String? databasePath;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = databasePath ?? path.join(await getDatabasesPath(), FinChatDatabaseSchema.databaseName);
    _database = await _factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: FinChatDatabaseSchema.version,
        onCreate: FinChatDatabaseSchema.onCreate,
        onUpgrade: FinChatDatabaseSchema.onUpgrade,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
    return _database!;
  }

  Future<void> ensureUser({required String userId, String? email}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'users',
      {
        'id': userId,
        'email': email ?? userId,
        'display_name': email ?? userId,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }
}
