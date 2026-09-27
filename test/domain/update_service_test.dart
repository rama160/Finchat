import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/update/update_service.dart';
import 'package:finchat/domain/update/app_update.dart';

class FakeUpdateProvider implements UpdateProvider {
  FakeUpdateProvider(this.result);
  final AppUpdate? result;
  String? currentVersion;

  @override
  Future<AppUpdate?> checkForUpdate({required String currentVersion}) async {
    this.currentVersion = currentVersion;
    return result;
  }
}

void main() {
  test('passes current version to update provider', () async {
    final provider = FakeUpdateProvider(null);
    final service = UpdateService(provider);
    final result = await service.check(currentVersion: '0.1.0+1');
    expect(result, isNull);
    expect(provider.currentVersion, '0.1.0+1');
  });
}
