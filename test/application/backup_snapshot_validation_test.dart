import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/domain/backup/backup_models.dart';

void main() {
  Map<String, Object?> validJson() => {'format_version': BackupSnapshot.currentFormatVersion, 'created_at': '2026-09-28T00:00:00.000Z', 'tables': {'users': <Map<String, Object?>>[], 'categories': <Map<String, Object?>>[], 'transactions': <Map<String, Object?>>[], 'category_mappings': <Map<String, Object?>>[], 'category_history': <Map<String, Object?>>[], 'app_settings': <Map<String, Object?>>[]}};
  test('rejects incomplete backups', () { final json = validJson(); (json['tables'] as Map<String, Object?>).remove('transactions'); expect(() => BackupSnapshot.fromJson(json)..validateForRestore(), throwsA(isA<FormatException>())); });
  test('rejects unsupported backup columns', () { final json = validJson(); final tables = json['tables'] as Map<String, Object?>; (tables['users'] as List<Map<String, Object?>>).add({'unexpected': true}); expect(() => BackupSnapshot.fromJson(json)..validateForRestore(), throwsA(isA<FormatException>())); });
  test('rejects incomplete table rows', () { final json = validJson(); final tables = json['tables'] as Map<String, Object?>; (tables['users'] as List<Map<String, Object?>>).add({'id': 'u'}); expect(() => BackupSnapshot.fromJson(json)..validateForRestore(), throwsA(isA<FormatException>())); });
  test('rejects invalid transaction confidence', () { final json = validJson(); final tables = json['tables'] as Map<String, Object?>; (tables['transactions'] as List<Map<String, Object?>>).add({'id':'tx','user_id':'u','type':'expense','amount':10,'description':'x','category_id':'makanan','transaction_date':1,'transaction_time':null,'input_source':'text','processed_by':'localParser','confidence':2,'created_at':1,'updated_at':1,'deleted_at':null,'sync_status':'local'}); expect(() => BackupSnapshot.fromJson(json)..validateForRestore(), throwsA(isA<FormatException>())); });
}
