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
}

abstract interface class CloudBackupProvider {
  Future<void> upload(BackupSnapshot snapshot);

  Future<BackupSnapshot?> download();
}
