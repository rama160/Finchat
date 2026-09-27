import 'dart:convert';
import 'dart:io';

import '../../domain/update/app_update.dart';

class GitHubReleaseUpdateProvider implements UpdateProvider {
  GitHubReleaseUpdateProvider({
    required this.owner,
    required this.repository,
    HttpClient? client,
  }) : _client = client ?? HttpClient();

  final String owner;
  final String repository;
  final HttpClient _client;

  @override
  Future<AppUpdate?> checkForUpdate({required String currentVersion}) async {
    final uri = Uri.https(
      'api.github.com',
      '/repos/$owner/$repository/releases/latest',
    );
    final request = await _client.getUrl(uri);
    request.headers
      ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
      ..set(HttpHeaders.userAgentHeader, 'FinChat-App');

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'GitHub release check failed: HTTP ${response.statusCode}',
        uri: uri,
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const FormatException('GitHub release response is not an object.');
    }

    final tag = decoded['tag_name'];
    final htmlUrl = decoded['html_url'];
    if (tag is! String || htmlUrl is! String) {
      throw const FormatException('GitHub release response is incomplete.');
    }

    final remoteVersion = _normalizeVersion(tag);
    final localVersion = _normalizeVersion(currentVersion);
    if (_compareVersions(remoteVersion, localVersion) <= 0) return null;

    Uri? apkUrl;
    final assets = decoded['assets'];
    if (assets is List) {
      for (final asset in assets) {
        if (asset is Map && asset['name'] == 'app-release.apk') {
          final url = asset['browser_download_url'];
          if (url is String) apkUrl = Uri.tryParse(url);
          break;
        }
      }
    }

    return AppUpdate(
      version: remoteVersion,
      releaseUrl: Uri.parse(htmlUrl),
      apkUrl: apkUrl,
      notes: decoded['body'] is String ? decoded['body'] as String : null,
    );
  }

  static String _normalizeVersion(String value) {
    final trimmed = value.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)').firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Unsupported app version: $value');
    }
    return '${match.group(1)}.${match.group(2)}.${match.group(3)}';
  }

  static int _compareVersions(String left, String right) {
    final a = left.split('.').map(int.parse).toList();
    final b = right.split('.').map(int.parse).toList();
    for (var i = 0; i < 3; i++) {
      final result = a[i].compareTo(b[i]);
      if (result != 0) return result;
    }
    return 0;
  }
}
