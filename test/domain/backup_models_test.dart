import 'package:flutter_test/flutter_test.dart';

import 'package:finchat/domain/backup/backup_models.dart';

void main() {
  test('backup snapshot round-trips through JSON', () {
    final snapshot = BackupSnapshot(
      formatVersion: BackupSnapshot.currentFormatVersion,
      createdAt: DateTime.utc(2026, 9, 26, 10, 30),
      tables: {
        'users': [
          {
            'id': 'u1',
            'email': 'user@example.com',
            'display_name': 'User',
            'created_at': 1,
            'updated_at': 2,
          },
        ],
      },
    );

    final restored = BackupSnapshot.decode(snapshot.encode());

    expect(restored.formatVersion, snapshot.formatVersion);
    expect(restored.createdAt, snapshot.createdAt);
    expect(restored.tables, snapshot.tables);
  });

  test('rejects an unsupported backup version', () {
    expect(
      () => BackupSnapshot.fromJson({
        'format_version': 99,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'tables': <String, dynamic>{},
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
