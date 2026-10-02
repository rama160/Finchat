import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../../application/ai/ai_secure_config_service.dart';
import '../../domain/ai/ai_category_fallback.dart';
import '../../domain/ai/financial_ai_provider.dart';

class OpenAiCompatibleAiProvider implements AiCategoryProvider, FinancialAiProvider {
  OpenAiCompatibleAiProvider({AiSecureConfigService? config, http.Client? client, Future<String?> Function()? idTokenProvider}) : _client = client ?? http.Client(), _idTokenProvider = idTokenProvider ?? _currentGoogleIdToken;
  final Future<String?> Function() _idTokenProvider;
  static const _gatewayEndpoint = 'https://finchat-ai-gateway.finchat-ai-gateway.workers.dev/v1/ai/chat';

  static Future<String?> _currentGoogleIdToken() async {
    final account = GoogleSignIn.instance.currentUser;
    if (account == null) return null;
    return (await account.authentication).idToken;
  }
  final http.Client _client;

  @override
  Future<AiCategorySuggestion?> suggestCategory(AiCategoryRequest request) async {
    final response = await _chat(_categoryPrompt(request));
    if (response == null) return null;
    try {
      final decoded = jsonDecode(response);
      if (decoded is! Map) return null;
      final categoryId = decoded['category_id'];
      final confidence = decoded['confidence'];
      if (categoryId is! String || confidence is! num) return null;
      return AiCategorySuggestion(categoryId: categoryId.trim(), confidence: confidence.toDouble());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> answer(FinancialAiRequest request) => _chat(_qaPrompt(request));

  Future<String?> _chat(String prompt) async {
    final idToken = await _idTokenProvider();
    if (idToken == null || idToken.trim().isEmpty) return null;
    final uri = Uri.parse(_gatewayEndpoint);
    try {
      final result = await _client.post(
        uri,
        headers: {'Authorization': 'Bearer ${idToken.trim()}', 'Content-Type': 'application/json'},
        body: jsonEncode({'messages': [
          {'role': 'user', 'text': 'Anda adalah asisten keuangan pribadi. Jangan mengarang data. Gunakan hanya data yang diberikan aplikasi. Untuk klasifikasi kategori, keluarkan JSON yang diminta.\n\n$prompt'},
        ], 'temperature': 0.1, 'maxOutputTokens': 1024}),
      ).timeout(const Duration(seconds: 25));
      if (result.statusCode < 200 || result.statusCode >= 300) return null;
      if (result.body.length > 1024 * 1024) return null;
      final body = jsonDecode(result.body);
      if (body is! Map || body['text'] is! String) return null;
      final content = (body['text'] as String).trim();
      if (content.isEmpty || content.length > 20000) return null;
      return content;
    } catch (_) {
      return null;
    }
  }

  String _categoryPrompt(AiCategoryRequest request) => '''Klasifikasikan transaksi ke salah satu category_id yang sudah tersedia di aplikasi. Jangan membuat category_id baru.\n\ncategory_id lokal: ${request.localCategoryId}\ndeskripsi: ${request.description}\ntipe: ${request.type.name}\njumlah: ${request.amount}\ninput asli: ${request.originalText}\n\nKembalikan hanya JSON valid: {"category_id":"...","confidence":0.0}. confidence harus 0 sampai 1.''';

  String _qaPrompt(FinancialAiRequest request) {
    final transactions = request.transactions.map((item) => {'date': item.transactionDate.toIso8601String().substring(0, 10), 'type': item.type.name, 'amount': item.amount, 'description': item.description, 'category_id': item.categoryId}).toList();
    return '''Jawab pertanyaan pengguna berdasarkan data keuangan terhitung berikut. Jangan mengubah atau mengarang angka. Jika data tidak cukup, katakan data tidak cukup. Berikan jawaban singkat dan praktis dalam Bahasa Indonesia.\n\nPeriode: ${request.start.toIso8601String()} sampai ${request.endExclusive.toIso8601String()}\nPemasukan: ${request.incomeTotal}\nPengeluaran: ${request.expenseTotal}\nSaldo: ${request.balance}\nTransaksi: ${jsonEncode(transactions)}\n\nPertanyaan: ${request.question}''';
  }
}
