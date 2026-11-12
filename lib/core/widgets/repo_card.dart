// ==============================================================================
// 📌 DOSYA: lib/core/widgets/repo_card.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Teslim edilen GitHub reposunu (sahip, depo adı, aktif dal) görselleştiren
//           ve harici tarayıcıda tek tıkla açılmasını sağlayan bilgi kartı.
// 📋 İÇERİK:
//   - Repo ikonu, sahip/repo adı, dal adı (branch)
//   - Harici bağlantı butonu (url_launcher kullanarak GitHub web sayfasına yönlendirme)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// GitHub deposu özetini gösteren ve harici açma imkanı sunan kart
class RepoCard extends StatelessWidget {
  /// Repo sahibi (örn: octocat)
  final String owner;

  /// Repo adı (örn: edutrack-app)
  final String repo;

  /// Git dalı (örn: main)
  final String? branch;

  /// Doğrudan repo web URL'i (isteğe bağlı, boşsa https://github.com/owner/repo üretilir)
  final String? repoUrl;

  const RepoCard({
    super.key,
    required this.owner,
    required this.repo,
    this.branch,
    this.repoUrl,
  });

  /// URL'i harici tarayıcı veya GitHub uygulamasında açar
  Future<void> _launchUrl(BuildContext context) async {
    final targetUrl = repoUrl ?? 'https://github.com/$owner/$repo';
    final uri = Uri.tryParse(targetUrl);
    if (uri != null) {
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repo bağlantısı açılamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.code_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$owner / $repo',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.fork_right_rounded, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        branch ?? 'default branch',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 20, color: AppColors.secondary),
              tooltip: "GitHub'da Aç",
              onPressed: () => _launchUrl(context),
            ),
          ],
        ),
      ),
    );
  }
}
