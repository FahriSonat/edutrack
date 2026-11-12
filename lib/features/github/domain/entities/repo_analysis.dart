// ==============================================================================
// 📌 DOSYA: lib/features/github/domain/entities/repo_analysis.dart
// 📌 AÇIKLAMA: GitHub REST API üzerinden çekilen repository ve commit analiz
//              çıktılarını (SHA, commit sayısı, son teslim sonrası commit) tutan model.
// ==============================================================================

/// [RepoAnalysis], bir GitHub deposunun teslim anındaki commit özetidir.
class RepoAnalysis {
  final String owner;
  final String repo;
  final String branch;
  final String latestCommitSha;
  final int commitCount;
  final int commitsAfterDeadline;
  final DateTime? firstCommitAt;
  final DateTime? lastCommitAt;

  const RepoAnalysis({
    required this.owner,
    required this.repo,
    required this.branch,
    required this.latestCommitSha,
    required this.commitCount,
    required this.commitsAfterDeadline,
    this.firstCommitAt,
    this.lastCommitAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'repoOwner': owner,
      'repoName': repo,
      'branch': branch,
      'latestCommitSha': latestCommitSha,
      'commitCount': commitCount,
      'commitsAfterDeadline': commitsAfterDeadline,
      'firstCommitAt': firstCommitAt?.toIso8601String(),
      'lastCommitAt': lastCommitAt?.toIso8601String(),
    };
  }
}

class GithubCommit {
  final String sha;
  final String message;
  final String authorName;
  final DateTime date;
  final bool isAfterDeadline;

  const GithubCommit({
    required this.sha,
    required this.message,
    required this.authorName,
    required this.date,
    this.isAfterDeadline = false,
  });
}
