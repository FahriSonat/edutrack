// ==============================================================================
// 📌 DOSYA: lib/features/github/domain/repositories/github_repository.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: GitHub REST API işlemlerini (repo analizi, commit geçmişi çekme)
//           soyutlayan domain repository arayüzü.
// 📋 İŞLEVLER:
//   - analyzeRepo: Reponun default branch, son commit sha, teslim sonrası commit sayısı
//                  gibi metriklerini hesaplar.
//   - getCommits: Repoya ait commit geçmişini ve teslim süresini aşan commit bayraklarını döner.
// ==============================================================================

import '../../../../core/error/result.dart';
import '../../domain/entities/repo_analysis.dart';

/// GitHub analiz servislerinin soyut arayüzü.
abstract class GithubRepository {
  /// Bir GitHub reposunu son teslim tarihi bağlamında inceler ve özet analiz çıkarır
  Future<Result<RepoAnalysis>> analyzeRepo({
    required String owner,
    required String repo,
    String? branch,
    required DateTime dueAt,
  });

  /// Reponun commit listesini ve her commit'in deadline durumunu döner
  Future<Result<List<GithubCommit>>> getCommits({
    required String owner,
    required String repo,
    String? branch,
    required DateTime dueAt,
  });
}
