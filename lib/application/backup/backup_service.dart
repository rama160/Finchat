import 'dart:convert';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../../data/local/finchat_database.dart';
import '../../domain/backup/backup_models.dart';

class BackupService {
  BackupService(this.database, {this.cloudProvider});

  final FinChatDatabase database;
  final CloudBackupProvider? cloudProvider;

  static const _tableOrder = [
    'users',
    'categories',
    'transactions',
    'category_mappings',
    'category_history',
    'app_settings',
  ];

  Future<BackupSnapshot> createSnapshot() async {
    final db = await database.database;
    final tables = <String, List<Map<String, Object?>>>{};
    for (final table in _tableOrder) {
      final rows = await db.query(table);
      tables[table] = rows
          .map((row) => Map<String, Object?>.from(row))
          .toList(growable: false);
    }
    return BackupSnapshot(
      formatVersion: BackupSnapshot.currentFormatVersion,
      createdAt: DateTime.now().toUtc(),
      tables: tables,
    );
  }

  Future<String> exportJson() async => (await createSnapshot()).encode();

  Future<Uint8List> exportBytes() async => Uint8List.fromList(
        utf8.encode(await exportJson()),
      );

  Future<void> restoreJson(String json) async {
    await restoreSnapshot(BackupSnapshot.decode(json));
  }

  Future<void> restoreSnapshot(BackupSnapshot snapshot) async {
    final db = await database.database;
    await db.transaction((txn) async {
      await txn.delete('category_history');
      await txn.delete('category_mappings');
      await txn.delete('transactions');
      await txn.delete('app_settings');
      await txn.delete('categories');
      await txn.delete('users');

      for (final table in _tableOrder) {
        final rows = snapshot.tables[table] ?? const [];
        for (final row in rows) {
          await txn.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }

  Future<void> backupToCloud() async {
    final provider = cloudProvider;
    if (provider == null) {
      throw StateError('Cloud backup provider belum dikonfigurasi.');
    }
    await provider.upload(await createSnapshot());
  }

  Future<bool> restoreFromCloud() async {
    final provider = cloudProvider;
    if (provider == null) {
      throw StateError('Cloud backup provider belum dikonfigurasi.');
    }
    final snapshot = await provider.download();
    if (snapshot == null) return false;
    await restoreSnapshot(snapshot);
    return true;
  }
}
