// ==============================================================================
// 📌 DOSYA: lib/core/utils/github_url_parser.dart
// 📌 AÇIKLAMA: Kullanıcının girdiği GitHub repository bağlantısını regex ile
//              ayrıştırarak 'owner' ve 'repo' ikilisini çıkaran yardımcı sınıf.
// ==============================================================================

/// [ParsedGithubUrl], ayrıştırılmış GitHub repo sahibi ve repo adını taşır.
class ParsedGithubUrl {
  /// Depo sahibi (Kullanıcı veya Organizasyon adı)
  final String owner;

  /// Depo adı
  final String repo;

  const ParsedGithubUrl({
    required this.owner,
    required this.repo,
  });

  /// Standartlaştırılmış 'owner/repo' tam adını döner
  String get fullName => '$owner/$repo';

  /// Tarayıcıda açılmaya uygun temiz HTTPS bağlantısı
  String get httpsUrl => 'https://github.com/$owner/$repo';

  @override
  String toString() => 'ParsedGithubUrl($fullName)';
}

/// [GithubUrlParser], çeşitli formatlardaki GitHub URL'lerini doğrular ve parse eder.
class GithubUrlParser {
  GithubUrlParser._();

  // Desteklenen formatlar:
  // - https://github.com/owner/repo
  // - http://github.com/owner/repo
  // - github.com/owner/repo
  // - https://github.com/owner/repo.git
  // - https://github.com/owner/repo/
  static final RegExp _regex = RegExp(
    r'^(?:https?:\/\/)?(?:www\.)?github\.com\/([a-zA-Z0-9_.-]+)\/([a-zA-Z0-9_.-]+?)(?:\.git)?(?:\/.*)?$',
  );

  /// Verilen URL stringini ayrıştırır; geçersiz format ise `null` döner.
  static ParsedGithubUrl? parse(String? rawUrl) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    final match = _regex.firstMatch(trimmed);
    if (match == null) return null;

    final owner = match.group(1);
    final repo = match.group(2);

    if (owner == null || repo == null || owner.isEmpty || repo.isEmpty) {
      return null;
    }

    return ParsedGithubUrl(owner: owner, repo: repo);
  }

  /// URL'in geçerli bir GitHub repository linki olup olmadığını kontrol eder.
  static bool isValid(String? rawUrl) => parse(rawUrl) != null;
}
