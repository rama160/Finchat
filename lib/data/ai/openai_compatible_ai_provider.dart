
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../application/ai/ai_secure_config_service.dart';
import '../../domain/ai/ai_category_fallback.dart';
import '../../domain/ai/financial_ai_provider.dart';

class OpenAiCompatibleAiProvider
    implements AiCategoryProvider, FinancialAiProvider {
  OpenAiCompatibleAiProvider({
    AiSecureConfigService? config,
    http.Client? client,
    Future<String?> Function()? idTokenProvider,
  })  : _config = config ?? AiSecureConfigService(),
        _client = client ?? http.Client(),
        _idTokenProvider = idTokenProvider ?? _currentGoogleIdToken;

  final AiSecureConfigService _config;
  final http.Client _client;
  final Future<String?> Function() _idTokenProvider;

  static const String _webClientId =
      '515697505386-r2ahk5fv1oa93dh6549h25ekllo85rfq.apps.googleusercontent.com';

  static const String _gatewayEndpoint =
      'https://finchat-ai-gateway.finchat-ai-gateway.workers.dev/v1/ai/chat';

  static bool _googleSignInInitialized = false;

  /// Inisialisasi Google Sign-In dan ambil ID Token akun yang login.
  static Future<String?> _currentGoogleIdToken() async {
    try {
      if (!_googleSignInInitialized) {
        await GoogleSignIn.instance.initialize(
          serverClientId: _webClientId,
        );
        _googleSignInInitialized = true;
      }

      final account =
          await GoogleSignIn.instance.attemptLightweightAuthentication();

      if (account == null) {
        return null;
      }

      final authentication = account.authentication;
      return authentication.idToken;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AiCategorySuggestion?> suggestCategory(
    AiCategoryRequest request,
  ) async {
    final response = await _chat(_categoryPrompt(request));

    if (response == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(response);

      if (decoded is! Map) {
        return null;
      }

      final categoryId = decoded['category_id'];
      final confidence = decoded['confidence'];

      if (categoryId is! String || confidence is! num) {
        return null;
      }

      final normalizedCategoryId = categoryId.trim();
      final normalizedConfidence = confidence.toDouble();

      if (normalizedCategoryId.isEmpty ||
          normalizedConfidence < 0 ||
          normalizedConfidence > 1) {
        return null;
      }

      return AiCategorySuggestion(
        categoryId: normalizedCategoryId,
        confidence: normalizedConfidence,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> answer(FinancialAiRequest request) {
    return _chat(_qaPrompt(request));
  }

  /// Kirim prompt ke Cloudflare Gateway menggunakan Google ID Token.
  /// Gemini API Key tidak disimpan atau dikirim dari aplikasi Flutter.
  Future<String?> _chat(String prompt) async {
    try {
      if (!await _config.readEnabled()) {
        return null;
      }

      final idToken = await _idTokenProvider();

      if (idToken == null || idToken.trim().isEmpty) {
        return null;
      }

      final uri = Uri.parse(_gatewayEndpoint);

      final result = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${idToken.trim()}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'messages': [
                {
                  'role': 'user',
                  'text':
                      'Anda adalah asisten keuangan pribadi. '
                      'Jangan mengarang data. Gunakan hanya data '
                      'yang diberikan aplikasi. Untuk klasifikasi '
                      'kategori, keluarkan JSON yang diminta.\n\n'
                      '$prompt',
                },
              ],
              'temperature': 0.1,
              'maxOutputTokens': 1024,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (result.statusCode < 200 || result.statusCode >= 300) {
        return null;
      }

      if (result.body.length > 1024 * 1024) {
        return null;
      }

      final body = jsonDecode(result.body);

      if (body is! Map || body['text'] is! String) {
        return null;
      }

      final content = (body['text'] as String).trim();

      if (content.isEmpty || content.length > 20000) {
        return null;
      }

      return content;
    } catch (_) {
      return null;
    }
  }

  String _categoryPrompt(AiCategoryRequest request) {
    return '''
Klasifikasikan transaksi ke salah satu category_id yang sudah tersedia
di aplikasi. Jangan membuat category_id baru.

category_id lokal: ${request.localCategoryId}
deskripsi: ${request.description}
tipe: ${request.type.name}
jumlah: ${request.amount}
input asli: ${request.originalText}

Kembalikan hanya JSON valid:
{"category_id":"...","confidence":0.0}

confidence harus 0 sampai 1.
''';
  }

  String _qaPrompt(FinancialAiRequest request) {
    final transactions = request.transactions
        .map(
          (item) => {
            'date':
                item.transactionDate.toIso8601String().substring(0, 10),
            'type': item.type.name,
            'amount': item.amount,
            'description': item.description,
            'category_id': item.categoryId,
          },
        )
        .toList();

    return '''
Jawab pertanyaan pengguna berdasarkan data keuangan terhitung berikut.
Jangan mengubah atau mengarang angka. Jika data tidak cukup, katakan
data tidak cukup. Berikan jawaban singkat dan praktis dalam Bahasa Indonesia.

Periode: ${request.start.toIso8601String()} sampai
${request.endExclusive.toIso8601String()}

Pemasukan: ${request.incomeTotal}
Pengeluaran: ${request.expenseTotal}
Saldo: ${request.balance}
Transaksi: ${jsonEncode(transactions)}

Pertanyaan: ${request.question}
''';
  }
}
