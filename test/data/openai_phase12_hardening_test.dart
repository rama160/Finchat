import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:finchat/application/ai/ai_secure_config_service.dart';
import 'package:finchat/data/ai/openai_compatible_ai_provider.dart';
import 'package:finchat/domain/ai/ai_category_fallback.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';

void main() {

  test('production Gateway provider does not require the legacy local AI toggle', () async {
    var calls = 0;
    final provider = OpenAiCompatibleAiProvider(
      client: MockClient((request) async {
        calls++;
        expect(request.url.toString(), contains('/v1/ai/chat'));
        expect(request.headers['authorization'], 'Bearer test-token');
        return http.Response(
          '{"text":"{\"category_id\":\"makanan\",\"confidence\":0.9}"}',
          200,
        );
      }),
      idTokenProvider: () async => 'test-token',
    );

    final result = await provider.suggestCategory(const AiCategoryRequest(
      userId: 'u',
      originalText: 'nasi 20rb',
      description: 'nasi',
      type: TransactionType.expense,
      amount: 20000,
      localCategoryId: 'lainnya',
    ));

    expect(result?.categoryId, 'makanan');
    expect(calls, 1);
  });

  test('disabled AI does not call network', () async {
    var calls = 0; final store = _Store(); final config = AiSecureConfigService(store: store);
    await config.save(apiKey: '', endpoint: '', model: '', enabled: false);
    final provider = OpenAiCompatibleAiProvider(config: config, client: MockClient((_) async { calls++; return http.Response('{}', 200); }));
    final result = await provider.suggestCategory(const AiCategoryRequest(userId:'u',originalText:'x',description:'x',type:TransactionType.expense,amount:1,localCategoryId:'lainnya'));
    expect(result, isNull); expect(calls, 0);
  });
  test('enabled AI rejects insecure endpoint', () async { final config = AiSecureConfigService(store: _Store()); expect(() => config.save(apiKey:'key',endpoint:'http://example.com',model:'m',enabled:true), throwsA(isA<FormatException>())); });
  test('provider rejects oversized response', () async { final store=_Store(); final config=AiSecureConfigService(store:store); await config.save(apiKey:'key',endpoint:'https://example.com/v1/chat/completions',model:'m',enabled:true); final provider=OpenAiCompatibleAiProvider(config:config,client:MockClient((_) async => http.Response('x' * (1024*1024+1),200)), idTokenProvider: () async => 'test-token'); final result=await provider.suggestCategory(const AiCategoryRequest(userId:'u',originalText:'x',description:'x',type:TransactionType.expense,amount:1,localCategoryId:'lainnya')); expect(result,isNull); });
}
class _Store implements AiSecureStore { final values=<String,String>{}; @override Future<String?> read({required String key}) async=>values[key]; @override Future<void> write({required String key,required String value}) async{values[key]=value;} @override Future<void> delete({required String key}) async{values.remove(key);} }
