import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'database_schema.dart';

class FinChatDatabase {
  /// All production callers use one shared database handle so a secondary
  /// screen cannot close the connection while ChatScreen is still using it.
  /// Tests/custom callers can still create an isolated instance by supplying
  /// a factory and/or databasePath.
  factory FinChatDatabase({DatabaseFactory? factory, String? databasePath}) {
    if (factory == null && databasePath == null) {
      return _shared;
    }
    return FinChatDatabase._(
      factory ?? databaseFactory,
      databasePath,
      shared: false,
    );
  }

  FinChatDatabase._(this._factory, this.databasePath, {required this.shared});

  static final FinChatDatabase _shared = FinChatDatabase._(
    databaseFactory,
    null,
    shared: true,
  );

  final DatabaseFactory _factory;
  final String? databasePath;
  final bool shared;

  Database? _database;
  Future<Database>? _opening;

  Future<Database> get database async {
    final current = _database;
    if (current != null && current.isOpen) {
      return current;
    }

    if (current != null && !current.isOpen) {
      _database = null;
    }

    final opening = _opening;
    if (opening != null) return opening;

    final future = _openDatabase();
    _opening = future;
    try {
      return await future;
    } finally {
      if (identical(_opening, future)) {
        _opening = null;
      }
    }
  }

  Future<Database> _openDatabase() async {
    final dbPath = databasePath ??
        path.join(
          await getDatabasesPath(),
          FinChatDatabaseSchema.databaseName,
        );
    final db = await _factory.openDatabase(
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
    _database = db;
    return db;
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
    // Production screens share the singleton. They must not close the shared
    // connection from an individual screen's dispose() method.
    if (shared) return;

    final db = _database;
    _database = null;
    await db?.close();
  }
}
