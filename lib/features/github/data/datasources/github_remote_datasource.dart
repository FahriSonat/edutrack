// ==============================================================================
// 📌 DOSYA: lib/features/github/data/datasources/github_remote_datasource.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: GitHub REST API üzerinden repository ve commit verilerini çeken
//           uzak veri kaynağı implementasyonu.
// 📋 İŞLEVLER:
//   - analyzeRepo: Reponun public olup olmadığını denetler, default branch'i bulur,
//     son 100 commiti listeler, ilk ve son commit tarihlerini alır, teslim tarihinden
//     sonra atılan commitleri (afterDeadline) sayar.
//   - getCommits: Repoya ait son 50 commit'i çeker ve her birinin son teslim tarihini
//     aşıp aşmadığını (`isAfterDeadline`) işaretler.
//   - Rate limit (403, x-ratelimit-remaining) ve 404 (Not Found / Private) hatalarını yönetir.
// ==============================================================================

import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/repo_analysis.dart';

/// GitHub uzak API sözleşmesi
abstract class GithubRemoteDataSource {
  Future<RepoAnalysis> analyzeRepo({
    required String owner,
    required String repo,
    String? branch,
    required DateTime dueAt,
  });

  Future<List<GithubCommit>> getCommits({
    required String owner,
    required String repo,
    String? branch,
    required DateTime dueAt,
  });
}

/// Dio HTTP istemcisiyle GitHub REST API uç noktalarını çağıran sınıf
class GithubRemoteDataSourceImpl implements GithubRemoteDataSource {
  final Dio dio;

  GithubRemoteDataSourceImpl(this.dio);

  /// Repoyu analiz ederek [RepoAnalysis] nesnesi üretir
  @override
  Future<RepoAnalysis> analyzeRepo({
    required String owner,
    required String repo,
    String? branch,
    required DateTime dueAt,
  }) async {
    try {
      // 1. Repo bilgisi ve default branch al
      final repoRes = await dio.get('/repos/$owner/$repo');
      final repoData = repoRes.data as Map<String, dynamic>;
      final isPrivate = repoData['private'] as bool? ?? false;
      if (isPrivate) {
        throw const Failure(
          message: 'Bu repo gizlidir (private). Lütfen herkese açık (public) bir repo adresi giriniz.',
        );
      }

      final targetBranch = (branch != null && branch.trim().isNotEmpty)
          ? branch.trim()
          : (repoData['default_branch'] as String? ?? 'main');

      // 2. Commit'leri al (ilk 100)
      final commitsRes = await dio.get(
        '/repos/$owner/$repo/commits',
        queryParameters: {
          'sha': targetBranch,
          'per_page': 100,
        },
      );

      final commitList = (commitsRes.data as List<dynamic>?) ?? [];
      if (commitList.isEmpty) {
        throw const Failure(message: 'Seçilen branch üzerinde henüz commit bulunamadı.');
      }

      final latestSha = commitList.first['sha'] as String? ?? '';

      // Commit tarihlerini committer.date üzerinden al
      DateTime? latestDate;
      DateTime? firstDate;

      final firstCommitObj = commitList.first['commit'] as Map<String, dynamic>?;
      final firstCommitter = firstCommitObj?['committer'] as Map<String, dynamic>?;
      if (firstCommitter?['date'] != null) {
        latestDate = DateTime.tryParse(firstCommitter!['date'] as String);
      }

      final lastCommitObj = commitList.last['commit'] as Map<String, dynamic>?;
      final lastCommitter = lastCommitObj?['committer'] as Map<String, dynamic>?;
      if (lastCommitter?['date'] != null) {
        firstDate = DateTime.tryParse(lastCommitter!['date'] as String);
      }

      // 3. Teslim tarihinden sonraki commit'leri sorgula
      int afterDeadlineCount = 0;
      try {
        final afterRes = await dio.get(
          '/repos/$owner/$repo/commits',
          queryParameters: {
            'sha': targetBranch,
            'since': dueAt.toUtc().toIso8601String(),
            'per_page': 100,
          },
        );
        final afterList = (afterRes.data as List<dynamic>?) ?? [];
        afterDeadlineCount = afterList.length;
      } catch (_) {
        // Fallback: Yerel commitList içinden filtrele
        afterDeadlineCount = commitList.where((c) {
          final committer =
              (c['commit'] as Map<String, dynamic>?)?['committer'] as Map<String, dynamic>?;
          if (committer?['date'] != null) {
            final date = DateTime.tryParse(committer!['date'] as String);
            return date != null && date.isAfter(dueAt);
          }
          return false;
        }).length;
      }

      return RepoAnalysis(
        owner: owner,
        repo: repo,
        branch: targetBranch,
        latestCommitSha: latestSha,
        commitCount: commitList.length,
        commitsAfterDeadline: afterDeadlineCount,
        firstCommitAt: firstDate,
        lastCommitAt: latestDate,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const Failure(
          message: 'Repo bulunamadı veya gizli (private). Lütfen bağlantıyı kontrol ediniz.',
        );
      }
      final remaining = e.response?.headers.value('x-ratelimit-remaining');
      if (e.response?.statusCode == 403 || remaining == '0') {
        throw const Failure(
          message: 'GitHub API saatlik istek limiti aşıldı. Lütfen bir süre sonra tekrar deneyiniz.',
        );
      }
      throw Failure(
        message: 'GitHub ile iletişim kurulamadı: ${e.message ?? "Bilinmeyen ağ hatası"}',
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(message: 'Repo incelenirken bir hata oluştu: $e');
    }
  }

  /// Repodaki son commit'leri çeker
  @override
  Future<List<GithubCommit>> getCommits({
    required String owner,
    required String repo,
    String? branch,
    required DateTime dueAt,
  }) async {
    try {
      final commitsRes = await dio.get(
        '/repos/$owner/$repo/commits',
        queryParameters: {
          if (branch != null && branch.isNotEmpty) 'sha': branch,
          'per_page': 50,
        },
      );

      final list = (commitsRes.data as List<dynamic>?) ?? [];
      return list.map((item) {
        final sha = item['sha'] as String? ?? '';
        final commit = item['commit'] as Map<String, dynamic>? ?? {};
        final message = commit['message'] as String? ?? '';
        final committer = commit['committer'] as Map<String, dynamic>?;
        final date = committer?['date'] != null
            ? DateTime.tryParse(committer!['date'] as String) ?? DateTime.now()
            : DateTime.now();
        final authorName = committer?['name'] as String? ?? 'Bilinmeyen';

        return GithubCommit(
          sha: sha,
          message: message,
          authorName: authorName,
          date: date,
          isAfterDeadline: date.isAfter(dueAt),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
