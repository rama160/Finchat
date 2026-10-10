import '../privacy/data_operation_gate.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../../data/local/finchat_database.dart';
import '../../domain/backup/backup_models.dart';

class BackupService {
  BackupService(
    this.database, {
    this.cloudProvider,
    this.restoreUserId,
    this.restoreUserEmail,
  });

  final FinChatDatabase database;
  final CloudBackupProvider? cloudProvider;
  final String? restoreUserId;
  final String? restoreUserEmail;

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
    await db.transaction((txn) async {
      for (final table in _tableOrder) {
        final rows = await txn.query(table);
        tables[table] = rows
            .map((row) => Map<String, Object?>.from(row))
            .toList(growable: false);
      }
    });
    return BackupSnapshot(
      formatVersion: BackupSnapshot.currentFormatVersion,
      createdAt: DateTime.now().toUtc(),
      tables: tables,
    );
  }

  Future<String> exportJson() async => (await createSnapshot()).encode();

  Future<Uint8List> exportBytes() async =>
      Uint8List.fromList(utf8.encode(await exportJson()));

  Future<void> restoreBytes(List<int> bytes) => restoreJson(utf8.decode(bytes));

  Future<void> restoreJson(String json) async {
    await restoreSnapshot(BackupSnapshot.decode(json));
  }

  Future<void> restoreSnapshot(BackupSnapshot snapshot) async {
    snapshot.validateForRestore();
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
        for (final originalRow in rows) {
          final row = Map<String, Object?>.from(originalRow);
          if (snapshot.isLegacy && restoreUserId != null) {
            if (table == 'users' && row['id'] == 'local_user') {
              row['id'] = restoreUserId;
              row['email'] = restoreUserEmail ?? row['email'];
              row['display_name'] = restoreUserEmail ?? row['display_name'];
            } else if ((table == 'transactions' ||
                    table == 'category_mappings' ||
                    table == 'category_history') &&
                row['user_id'] == 'local_user') {
              row['user_id'] = restoreUserId;
            }
          }
          await txn.insert(
            table,
            row,
            conflictAlgorithm: ConflictAlgorithm.abort,
          );
        }
      }
    });
  }

  Future<void> backupToCloud() => DataOperationGate.backup(_backupToCloud);

  Future<void> _backupToCloud() async {
    final provider = cloudProvider;
    if (provider == null) {
      throw StateError('Cloud backup provider belum dikonfigurasi.');
    }
    final snapshot = await createSnapshot();
    await provider.upload(snapshot);
    // Acknowledge only versions included in the successful cloud upload.
    // A transaction edited while uploading must remain locally pending.
    final db = await database.database;
    await db.transaction((txn) async {
      for (final row
          in snapshot.tables['transactions'] ?? <Map<String, Object?>>[]) {
        final fields = row.keys.where((key) => key != 'sync_status').toList();
        await txn.update(
          'transactions',
          {'sync_status': 'backed_up'},
          where: fields
              .map((key) => row[key] == null ? '$key IS NULL' : '$key = ?')
              .join(' AND '),
          whereArgs: fields
              .where((key) => row[key] != null)
              .map((key) => row[key])
              .toList(),
        );
      }
    });
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
