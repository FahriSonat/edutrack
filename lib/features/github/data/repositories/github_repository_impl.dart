// ==============================================================================
// 📌 DOSYA: lib/features/github/data/repositories/github_repository_impl.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: [GithubRepository] domain sözleşmesinin somut uygulaması.
// 📋 İŞLEVLER:
//   - RemoteDataSource üzerinden GitHub verilerini çekmek
//   - Ağ hatalarını ve istisnaları yakalayıp [Result.success] veya [Result.failure]
//     olarak sunuma iletmek
// ==============================================================================

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/repo_analysis.dart';
import '../../domain/repositories/github_repository.dart';
import '../datasources/github_remote_datasource.dart';

/// GitHub veri erişim ve analiz işlemlerini yürüten repository implementasyonu
class GithubRepositoryImpl implements GithubRepository {
  final GithubRemoteDataSource remoteDataSource;

  GithubRepositoryImpl(this.remoteDataSource);

  /// GitHub reposunu inceler ve sonucu Result içinde döndürür
  @override
  Future<Result<RepoAnalysis>> analyzeRepo({
    required String owner,
    required String repo,
    String? branch,
    required DateTime dueAt,
  }) async {
    try {
      final analysis = await remoteDataSource.analyzeRepo(
        owner: owner,
        repo: repo,
        branch: branch,
        dueAt: dueAt,
      );
      return Result.success(analysis);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Repo analizi başarısız oldu: $e'));
    }
  }

  /// Repodaki commit listesini Result içinde döndürür
  @override
  Future<Result<List<GithubCommit>>> getCommits({
    required String owner,
    required String repo,
    String? branch,
    required DateTime dueAt,
  }) async {
    try {
      final commits = await remoteDataSource.getCommits(
        owner: owner,
        repo: repo,
        branch: branch,
        dueAt: dueAt,
      );
      return Result.success(commits);
    } catch (e) {
      return Result.failure(Failure(message: 'Commit listesi alınamadı: $e'));
    }
  }
}
