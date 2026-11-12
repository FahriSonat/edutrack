// ==============================================================================
// 📌 DOSYA: lib/features/github/presentation/providers/github_providers.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: GitHub entegrasyonu için Riverpod Dependency Injection tanımları.
// 📋 İÇERİK:
//   - githubRemoteDataSourceProvider: Dio istemcisini kullanarak GitHub veri kaynağı üretir
//   - githubRepositoryProvider: GitHub repository katmanını dışa aktarır
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/github_dio.dart';
import '../../data/datasources/github_remote_datasource.dart';
import '../../data/repositories/github_repository_impl.dart';
import '../../domain/repositories/github_repository.dart';

/// GitHub uzak API veri kaynağı sağlayıcısı
final githubRemoteDataSourceProvider = Provider<GithubRemoteDataSource>((ref) {
  final dio = ref.watch(githubDioProvider);
  return GithubRemoteDataSourceImpl(dio);
});

/// GitHub repository sağlayıcısı
final githubRepositoryProvider = Provider<GithubRepository>((ref) {
  final remoteDataSource = ref.watch(githubRemoteDataSourceProvider);
  return GithubRepositoryImpl(remoteDataSource);
});
