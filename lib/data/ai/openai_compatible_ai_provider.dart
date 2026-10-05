import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../../application/ai/ai_secure_config_service.dart';
import '../../application/auth/google_sign_in_coordinator.dart';
import '../../domain/ai/ai_category_fallback.dart';
import '../../domain/ai/financial_ai_provider.dart';

class OpenAiCompatibleAiProvider
    implements AiCategoryProvider, FinancialAiProvider, FinancialAiAvailability {
  OpenAiCompatibleAiProvider({
    AiSecureConfigService? config,
    http.Client? client,
    this._idTokenProvider,
    GoogleSignInCoordinator? googleSignInCoordinator,
  })  : _legacyConfig = config,
        _client = client ?? http.Client(),
        _googleSignInCoordinator =
            googleSignInCoordinator ?? GoogleSignInCoordinator.instance;

  final AiSecureConfigService? _legacyConfig;
  final http.Client _client;
  final GoogleSignInCoordinator _googleSignInCoordinator;
  final Future<String?> Function()? _idTokenProvider;

  @override
  String? failureMessage;

  static const String _gatewayEndpoint =
      'https://finchat-ai-gateway.finchat-ai-gateway.workers.dev/v1/ai/chat';

  @override
  Future<AiCategorySuggestion?> suggestCategory(
    AiCategoryRequest request,
  ) async {
    final response = await _chat(_categoryPrompt(request));

    if (response == null) {
      return null;
    }

    try {
      final clean = response.replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '').replaceFirst(RegExp(r'\s*```$'), '');
      final decoded = jsonDecode(clean);

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
  /// Gemini API Key tetap hanya berada di server/Gateway.
  Future<String?> _chat(String prompt) async {
    failureMessage = null;
    try {
      // The production provider is Gateway-first. The old local AI enable
      // switch is only honored when a config object is explicitly injected,
      // which preserves the existing unit-test contract without disabling the
      // real Gateway in the app.
      final legacyConfig = _legacyConfig;
      if (legacyConfig != null && !await legacyConfig.readEnabled()) {
        return null;
      }

      final tokenProvider = _idTokenProvider;
      late final String? idToken;
      if (tokenProvider == null) {
        idToken = await _currentGoogleIdToken();
      } else {
        idToken = await tokenProvider();
      }

      if (idToken == null || idToken.trim().isEmpty) {
        failureMessage = 'Sesi AI Google belum dapat diperbarui. Coba lagi; bila tetap gagal, perbarui sesi melalui Pengaturan.';
        return null;
      }

      final uri = Uri.parse(_gatewayEndpoint);
      final text = 'Anda adalah asisten keuangan pribadi. Jangan mengarang data. '
          'Gunakan data aplikasi untuk angka keuangan pengguna. '
          'Untuk klasifikasi kategori, keluarkan JSON yang diminta.\n\n$prompt';
      final payload = jsonEncode({
        'messages': [{'role': 'user', 'text': text}],
        'temperature': 0.1,
        'maxOutputTokens': 1024,
      });
      if (text.length > 10000 || utf8.encode(payload).length > 20000) {
        failureMessage = 'Pertanyaan terlalu panjang. Gunakan pertanyaan yang lebih singkat.';
        return null;
      }

      final result = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${idToken.trim()}',
              'Content-Type': 'application/json',
            },
            body: payload,
          )
          .timeout(const Duration(seconds: 65));

      if (result.statusCode < 200 || result.statusCode >= 300) {
        failureMessage = switch (result.statusCode) {
          401 => 'Sesi Google ditolak Gateway. Masuk ulang dengan Google; konfigurasi client ID aplikasi dan Gateway harus sama.',
          403 => 'Akses AI ditolak Gateway. Periksa otorisasi akun dan konfigurasi Gateway.',
          429 => 'Batas pemakaian AI tercapai. Coba lagi setelah batas pemakaian diperbarui.',
          413 => 'Data untuk AI terlalu besar. Pilih rentang tanggal lebih pendek.',
          _ => 'Layanan AI belum berhasil menjawab (HTTP ${result.statusCode}). Coba lagi; data transaksi tetap tersimpan lokal.',
        };
        return null;
      }

      if (result.body.length > 1024 * 1024) {
        return null;
      }

      final body = jsonDecode(result.body);

      if (body is! Map || body['text'] is! String) {
        failureMessage = 'Jawaban Gateway tidak sesuai format. Periksa layanan AI Gateway.';
        return null;
      }

      final content = (body['text'] as String).trim();

      if (content.isEmpty || content.length > 20000) {
        return null;
      }

      return content;
    } on TimeoutException {
      failureMessage = 'Layanan AI melewati batas waktu. Coba lagi; pertanyaan umum tetap dapat dijawab lokal.';
      return null;
    } catch (_) {
      failureMessage = 'AI belum dapat dihubungi. Periksa koneksi internet dan coba lagi.';
      return null;
    }
  }

  Future<String?> _currentGoogleIdToken() async {
    try {
      return await _googleSignInCoordinator.currentIdToken();
    } catch (_) {
      return null;
    }
  }

  String _categoryPrompt(AiCategoryRequest request) {
    return '''
Klasifikasikan transaksi ke salah satu category_id yang sudah tersedia
di aplikasi. Jangan membuat category_id baru.

Daftar category_id valid: ${jsonEncode(request.availableCategoryIds)}
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
        .take(25)
        .map(
          (item) => {
            'date':
                item.transactionDate.toIso8601String().substring(0, 10),
            'type': item.type.name,
            'amount': item.amount,
            'description': item.description.length > 80 ? item.description.substring(0, 80) : item.description,
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
Jumlah transaksi seluruh periode: ${request.transactions.length}
Cuplikan maksimal 25 transaksi; cuplikan bukan seluruh transaksi. Jangan menyimpulkan rincian yang tidak tersedia dari cuplikan.
Transaksi cuplikan: ${jsonEncode(transactions)}

Pertanyaan: ${request.question}
''';
  }
}
