import 'dart:convert';

class BackupSnapshot {
  const BackupSnapshot({
    required this.formatVersion,
    required this.createdAt,
    required this.tables,
  });

  static const currentFormatVersion = 1;

  final int formatVersion;
  final DateTime createdAt;
  final Map<String, List<Map<String, Object?>>> tables;

  String encode() => jsonEncode(toJson());

  Map<String, Object?> toJson() => {
        'format_version': formatVersion,
        'created_at': createdAt.toUtc().toIso8601String(),
        'tables': tables,
      };

  factory BackupSnapshot.decode(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map) {
      throw const FormatException('Backup tidak memiliki format JSON object.');
    }
    return BackupSnapshot.fromJson(Map<String, Object?>.from(decoded));
  }

  factory BackupSnapshot.fromJson(Map<String, Object?> json) {
    final formatVersion = json['format_version'];
    final createdAt = json['created_at'];
    final rawTables = json['tables'];

    if (formatVersion is! int || createdAt is! String || rawTables is! Map) {
      throw const FormatException('Struktur backup tidak valid.');
    }
    if (formatVersion != currentFormatVersion) {
      throw FormatException(
        'Versi backup $formatVersion tidak didukung. Versi saat ini $currentFormatVersion.',
      );
    }

    final tables = <String, List<Map<String, Object?>>>{};
    for (final entry in rawTables.entries) {
      final rows = entry.value;
      if (rows is! List) {
        throw const FormatException('Isi tabel backup tidak valid.');
      }
      tables[entry.key.toString()] = rows
          .map((row) {
            if (row is! Map) {
              throw const FormatException('Baris backup tidak valid.');
            }
            return Map<String, Object?>.from(row);
          })
          .toList();
    }

    return BackupSnapshot(
      formatVersion: formatVersion,
      createdAt: DateTime.parse(createdAt).toUtc(),
      tables: tables,
    );
  }

  void validateForRestore() {
    const requiredTables = <String>{'users', 'categories', 'transactions', 'category_mappings', 'category_history', 'app_settings'};
    const columns = <String, Set<String>>{
      'users': {'id', 'email', 'display_name', 'created_at', 'updated_at'},
      'categories': {'id', 'name', 'type', 'is_system', 'created_at', 'updated_at'},
      'transactions': {'id', 'user_id', 'type', 'amount', 'description', 'category_id', 'transaction_date', 'transaction_time', 'input_source', 'processed_by', 'confidence', 'created_at', 'updated_at', 'deleted_at', 'sync_status'},
      'category_mappings': {'id', 'user_id', 'normalized_keyword', 'category_id', 'source', 'confidence', 'usage_count', 'last_used_at', 'created_at', 'updated_at'},
      'category_history': {'id', 'user_id', 'transaction_id', 'keyword', 'previous_category_id', 'new_category_id', 'source', 'created_at'},
      'app_settings': {'key', 'value', 'updated_at'},
    };
    if (!tables.keys.toSet().containsAll(requiredTables)) throw const FormatException('Backup tidak lengkap: tabel FinChat yang wajib tidak tersedia.');
    final unknown = tables.keys.where((key) => !requiredTables.contains(key));
    if (unknown.isNotEmpty) throw FormatException('Backup memiliki tabel yang tidak didukung: ${unknown.join(', ')}.');
    for (final entry in tables.entries) {
      final allowed = columns[entry.key]!;
      for (final row in entry.value) {
        if (row.keys.any((key) => !allowed.contains(key))) throw FormatException('Backup tabel ${entry.key} memiliki kolom yang tidak didukung.');
        if (!row.keys.toSet().containsAll(allowed)) throw FormatException('Backup tabel ${entry.key} tidak memiliki kolom yang lengkap.');
      }
    }
    for (final row in tables['transactions']!) {
      final amount = row['amount'];
      final confidence = row['confidence'];
      if (amount is! num || !amount.isFinite || amount <= 0) throw const FormatException('Backup memiliki nominal transaksi yang tidak valid.');
      if (confidence is! num || !confidence.isFinite || confidence < 0 || confidence > 1) throw const FormatException('Backup memiliki confidence transaksi yang tidak valid.');
    }
  }
}

abstract interface class CloudBackupProvider {
  Future<void> upload(BackupSnapshot snapshot);

  Future<BackupSnapshot?> download();
}
