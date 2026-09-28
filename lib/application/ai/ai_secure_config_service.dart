import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AiSecureStore {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
}

class FlutterAiSecureStore implements AiSecureStore {
  FlutterAiSecureStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;
  @override Future<String?> read({required String key}) => _storage.read(key: key);
  @override Future<void> write({required String key, required String value}) => _storage.write(key: key, value: value);
  @override Future<void> delete({required String key}) => _storage.delete(key: key);
}

class AiSecureConfigService {
  AiSecureConfigService({AiSecureStore? store}) : _store = store ?? FlutterAiSecureStore();
  final AiSecureStore _store;
  static const apiKeyKey = 'ai.api_key';
  static const endpointKey = 'ai.endpoint';
  static const modelKey = 'ai.model';
  static const enabledKey = 'ai.enabled';

  Future<String?> readApiKey() => _store.read(key: apiKeyKey);
  Future<String?> readEndpoint() => _store.read(key: endpointKey);
  Future<String?> readModel() => _store.read(key: modelKey);
  Future<bool> readEnabled() async => (await _store.read(key: enabledKey)) == 'true';

  Future<void> save({required String apiKey, required String endpoint, required String model, required bool enabled}) async {
    final normalizedKey = apiKey.trim();
    final normalizedEndpoint = endpoint.trim();
    final normalizedModel = model.trim();
    if (enabled) {
      if (normalizedKey.isEmpty) throw const FormatException('API key wajib diisi ketika AI fallback aktif.');
      final uri = Uri.tryParse(normalizedEndpoint);
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) throw const FormatException('Endpoint AI aktif harus menggunakan URL HTTPS yang valid.');
      if (normalizedModel.isEmpty) throw const FormatException('Model AI wajib diisi ketika AI fallback aktif.');
    }
    await _store.write(key: apiKeyKey, value: normalizedKey);
    await _store.write(key: endpointKey, value: normalizedEndpoint);
    await _store.write(key: modelKey, value: normalizedModel);
    await _store.write(key: enabledKey, value: enabled ? 'true' : 'false');
  }

  Future<void> clearApiKey() => _store.delete(key: apiKeyKey);
}
