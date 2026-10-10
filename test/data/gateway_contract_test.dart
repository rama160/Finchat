import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:finchat/data/ai/openai_compatible_ai_provider.dart';
import 'package:finchat/domain/ai/financial_ai_provider.dart';
import 'package:finchat/domain/ai/ai_category_fallback.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';

FinancialAiRequest request() => FinancialAiRequest(question: 'Bagaimana berhemat?', start: DateTime(2026, 10), endExclusive: DateTime(2026, 11), transactions: const [], incomeTotal: 100000, expenseTotal: 50000, balance: 50000);

void main() {
  test('matches deployed Gateway role/text and bearer contract', () async {
    final provider = OpenAiCompatibleAiProvider(idTokenProvider: () async => 'token', client: MockClient((req) async {
      expect(req.url.path, '/v1/ai/chat');
      expect(req.headers['Authorization'], 'Bearer token');
      final payload = jsonDecode(req.body) as Map;
      expect(payload['messages'][0]['role'], 'user');
      expect(payload['messages'][0]['text'], contains('Pemasukan: 100000'));
      expect(req.bodyBytes.length, lessThan(20000));
      return http.Response(jsonEncode({'text': 'Jawaban'}), 200);
    }));
    expect(await provider.answer(request()), 'Jawaban');
  });
  test('exposes authentication and quota errors without exposing tokens', () async {
    for (final status in [401, 429, 503]) {
      final provider = OpenAiCompatibleAiProvider(idTokenProvider: () async => 'secret-token', client: MockClient((_) async => http.Response('{}', status)));
      expect(await provider.answer(request()), isNull);
      expect(provider.failureMessage, isNotEmpty);
      expect(provider.failureMessage, isNot(contains('secret-token')));
    }
  });
  test('accepts Gemini fenced category JSON', () async {
    final provider = OpenAiCompatibleAiProvider(idTokenProvider: () async => 'token', client: MockClient((_) async => http.Response(jsonEncode({'text': '```json\n{"category_id":"makanan","confidence":0.95}\n```'}), 200)));
    final result = await provider.suggestCategory(const AiCategoryRequest(userId: 'u', originalText: 'nasi 20rb', description: 'nasi', type: TransactionType.expense, amount: 20000, localCategoryId: 'lainnya'));
    expect(result?.categoryId, 'makanan');
  });
}
