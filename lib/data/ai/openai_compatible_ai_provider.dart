import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../application/ai/ai_secure_config_service.dart';
import '../../domain/ai/ai_category_fallback.dart';
import '../../domain/ai/financial_ai_provider.dart';

class OpenAiCompatibleAiProvider implements AiCategoryProvider, FinancialAiProvider {
  OpenAiCompatibleAiProvider({AiSecureConfigService? config, http.Client? client}) : _config = config ?? AiSecureConfigService(), _client = client ?? http.Client();
  final AiSecureConfigService _config;
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
    final enabled = await _config.readEnabled();
    final apiKey = await _config.readApiKey();
    final endpoint = await _config.readEndpoint();
    final model = await _config.readModel();
    if (!enabled || apiKey == null || apiKey.trim().isEmpty || endpoint == null || endpoint.trim().isEmpty || model == null || model.trim().isEmpty) return null;

    final uri = Uri.tryParse(endpoint);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    try {
      final result = await _client.post(
        uri,
        headers: {'Authorization': 'Bearer ${apiKey.trim()}', 'Content-Type': 'application/json'},
        body: jsonEncode({'model': model.trim(), 'temperature': 0.1, 'messages': [
          {'role': 'system', 'content': 'Anda adalah asisten keuangan pribadi. Jangan mengarang data. Gunakan hanya data yang diberikan aplikasi. Untuk klasifikasi kategori, keluarkan JSON yang diminta.'},
          {'role': 'user', 'content': prompt},
        ]}),
      ).timeout(const Duration(seconds: 20));
      if (result.statusCode < 200 || result.statusCode >= 300) return null;
      if (result.body.length > 1024 * 1024) return null;
      final body = jsonDecode(result.body);
      if (body is! Map) return null;
      final choices = body['choices'];
      if (choices is! List || choices.isEmpty || choices.first is! Map) return null;
      final message = choices.first['message'];
      if (message is! Map || message['content'] is! String) return null;
      final content = (message['content'] as String).trim();
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
