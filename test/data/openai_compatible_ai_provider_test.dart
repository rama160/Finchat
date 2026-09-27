import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:finchat/data/ai/openai_compatible_ai_provider.dart';
import 'package:finchat/application/ai/ai_secure_config_service.dart';
import 'package:finchat/domain/ai/ai_category_fallback.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';


void main() {
  test('parses category JSON from an OpenAI-compatible response', () async {
    final storage = _FakeStore();
    final client = MockClient((request) async => http.Response(jsonEncode({'choices':[{'message':{'content':'{"category_id":"makanan","confidence":0.91}'}}]}),200));
    final config = AiSecureConfigService(store: storage);
    await config.save(apiKey:'test', endpoint:'https://example.com/v1/chat/completions', model:'test-model', enabled:true);
    final provider = OpenAiCompatibleAiProvider(config: config, client: client);
    final result = await provider.suggestCategory(const AiCategoryRequest(userId:'u', originalText:'nasi 20rb', description:'nasi', type:TransactionType.expense, amount:20000, localCategoryId:'lainnya'));
    expect(result?.categoryId, 'makanan');
    expect(result?.confidence, .91);
  });

  test('returns null when AI is disabled', () async {
    final storage = _FakeStore();
    final config = AiSecureConfigService(store: storage);
    await config.save(apiKey:'', endpoint:'https://example.com', model:'x', enabled:false);
    final provider = OpenAiCompatibleAiProvider(config: config, client: MockClient((_) async => http.Response('{}',200)));
    final result = await provider.suggestCategory(const AiCategoryRequest(userId:'u', originalText:'x', description:'x', type:TransactionType.expense, amount:1, localCategoryId:'lainnya'));
    expect(result, isNull);
  });
}

class _FakeStore implements AiSecureStore {
  final values = <String, String>{};
  @override Future<String?> read({required String key}) async => values[key];
  @override Future<void> write({required String key, required String value}) async { values[key] = value; }
  @override Future<void> delete({required String key}) async { values.remove(key); }
}
