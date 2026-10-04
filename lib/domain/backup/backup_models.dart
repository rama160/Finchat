import 'dart:convert';

class BackupSnapshot {
  const BackupSnapshot({
    required this.formatVersion,
    required this.createdAt,
    required this.tables,
    this.isLegacy = false,
  });

  static const currentFormatVersion = 1;

  final int formatVersion;
  final DateTime createdAt;
  final Map<String, List<Map<String, Object?>>> tables;
  final bool isLegacy;

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
    final json = Map<String, Object?>.from(decoded);

    // Backward compatibility with the original FinChat backup format:
    // {format, version, created_at, transactions, deleted_transaction_ids}.
    if (json['format'] == 'finchat_backup' && json['version'] is int) {
      return BackupSnapshot.fromLegacyJson(json);
    }

    return BackupSnapshot.fromJson(json);
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

    final tables = _decodeTables(rawTables);
    return BackupSnapshot(
      formatVersion: formatVersion,
      createdAt: _parseCreatedAt(createdAt),
      tables: tables,
    );
  }

  factory BackupSnapshot.fromLegacyJson(Map<String, Object?> json) {
    final version = json['version'];
    final createdAt = json['created_at'];
    final rawTransactions = json['transactions'];

    if (version is! int || version != 1 || createdAt is! String || rawTransactions is! List) {
      throw const FormatException('Format backup lama tidak valid.');
    }

    final created = _parseCreatedAt(createdAt);
    final categoriesById = <String, Map<String, Object?>>{};
    final transactions = <Map<String, Object?>>[];

    for (final raw in rawTransactions) {
      if (raw is! Map) {
        throw const FormatException('Baris transaksi backup lama tidak valid.');
      }
      final row = Map<String, Object?>.from(raw);
      final id = row['id'];
      final type = row['type'];
      final amount = row['amount'];
      final description = row['description'];
      final categoryName = row['category'];
      final date = row['transaction_date'];
      final time = row['transaction_time'];

      if (id == null || type is! String || amount is! num || description is! String ||
          categoryName is! String || date is! String) {
        throw const FormatException('Struktur transaksi backup lama tidak valid.');
      }
      if (!amount.isFinite || amount <= 0) {
        throw const FormatException('Backup lama memiliki nominal transaksi yang tidak valid.');
      }

      final transactionType = type == 'income' ? 'income' : type == 'expense' ? 'expense' : null;
      if (transactionType == null) {
        throw FormatException('Jenis transaksi backup lama tidak didukung: $type.');
      }

      final transactionDate = _parseLegacyDateTime(date, time);
      final categoryId = _legacyCategoryId(categoryName);
      final now = transactionDate.millisecondsSinceEpoch;
      categoriesById.putIfAbsent(
        categoryId,
        () => {
          'id': categoryId,
          'name': categoryName,
          'type': transactionType,
          'is_system': _isKnownCategoryName(categoryName) ? 1 : 0,
          'created_at': created.millisecondsSinceEpoch,
          'updated_at': created.millisecondsSinceEpoch,
        },
      );

      transactions.add({
        'id': id.toString(),
        'user_id': 'local_user',
        'type': transactionType,
        'amount': amount.toDouble(),
        'description': description,
        'category_id': categoryId,
        'transaction_date': DateTime(transactionDate.year, transactionDate.month, transactionDate.day).millisecondsSinceEpoch,
        'transaction_time': transactionDate.millisecondsSinceEpoch,
        'input_source': _legacyInputSource(row['source']),
        'processed_by': 'localParser',
        'confidence': 1.0,
        'created_at': now,
        'updated_at': now,
        'deleted_at': null,
        'sync_status': 'local',
      });
    }

    final userTimestamp = created.millisecondsSinceEpoch;
    final tables = <String, List<Map<String, Object?>>>{
      'users': [
        {
          'id': 'local_user',
          'email': 'local_user',
          'display_name': 'local_user',
          'created_at': userTimestamp,
          'updated_at': userTimestamp,
        },
      ],
      'categories': categoriesById.values.toList(),
      'transactions': transactions,
      'category_mappings': const [],
      'category_history': const [],
      'app_settings': const [],
    };

    return BackupSnapshot(
      formatVersion: currentFormatVersion,
      createdAt: created,
      tables: tables,
      isLegacy: true,
    );
  }

  void validateForRestore() {
    const requiredTables = <String>{
      'users',
      'categories',
      'transactions',
      'category_mappings',
      'category_history',
      'app_settings',
    };
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

  static Map<String, List<Map<String, Object?>>> _decodeTables(Map rawTables) {
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
    return tables;
  }

  static DateTime _parseCreatedAt(String value) {
    try {
      return DateTime.parse(value).toUtc();
    } catch (_) {
      throw const FormatException('Tanggal pembuatan backup tidak valid.');
    }
  }

  static DateTime _parseLegacyDateTime(String date, Object? time) {
    final timeText = time is String && time.trim().isNotEmpty ? time.trim() : '00:00:00';
    try {
      return DateTime.parse('$date $timeText');
    } catch (_) {
      throw FormatException('Tanggal transaksi backup lama tidak valid: $date $timeText.');
    }
  }

  static bool _isKnownCategoryName(String name) {
    const known = <String>{
      'gaji',
      'bonus',
      'makanan',
      'belanja dapur',
      'transportasi',
      'tagihan',
      'kesehatan',
      'hiburan',
      'lainnya',
    };
    return known.contains(name.trim().toLowerCase());
  }

  static String _legacyCategoryId(String name) {
    final normalized = name.trim().toLowerCase();
    const known = <String, String>{
      'gaji': 'gaji',
      'bonus': 'bonus',
      'makanan': 'makanan',
      'belanja dapur': 'belanja_dapur',
      'transportasi': 'transportasi',
      'tagihan': 'tagihan',
      'kesehatan': 'kesehatan',
      'hiburan': 'hiburan',
      'lainnya': 'lainnya',
    };
    final existing = known[normalized];
    if (existing != null) return existing;
    final slug = normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'legacy_category' : 'legacy_$slug';
  }

  static String _legacyInputSource(Object? source) {
    switch (source?.toString()) {
      case 'voice':
        return 'voice';
      case 'attachment':
        return 'attachment';
      case 'camera':
        return 'camera';
      case 'manual':
        return 'manual';
      default:
        return 'text';
    }
  }
}

abstract interface class CloudBackupProvider {
  Future<void> upload(BackupSnapshot snapshot);

  Future<BackupSnapshot?> download();
}
