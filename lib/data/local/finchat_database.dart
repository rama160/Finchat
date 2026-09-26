import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'database_schema.dart';

class FinChatDatabase {
  FinChatDatabase({DatabaseFactory? factory, String? databasePath})
      : _factory = factory ?? databaseFactory,
        _databasePath = databasePath;

  final DatabaseFactory _factory;
  final String? _databasePath;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = _databasePath ?? path.join(await getDatabasesPath(), FinChatDatabaseSchema.databaseName);
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

  Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }
}
