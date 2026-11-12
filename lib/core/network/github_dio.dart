// ==============================================================================
// 📌 DOSYA: lib/core/network/github_dio.dart
// 📌 AÇIKLAMA: GitHub REST API çağrıları için yapılandırılmış Dio HTTP istemcisi.
//              Zaman aşımı (timeout), API sürümü ve Accept başlıklarını yönetir.
// ==============================================================================

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// GitHub REST API v3 için standart [Dio] istemcisi oluşturur.
/// - Base URL: `https://api.github.com`
/// - Bağlantı & Yanıt zaman aşımı: 10s / 15s
/// - Resmi GitHub API sürüm başlığı: `2022-11-28`
Dio buildGithubDio() => Dio(BaseOptions(
      baseUrl: 'https://api.github.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ));

/// Riverpod üzerinden [Dio] GitHub istemcisini sağlayan provider.
final githubDioProvider = Provider<Dio>((ref) {
  return buildGithubDio();
});
