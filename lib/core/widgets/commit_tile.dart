// ==============================================================================
// 📌 DOSYA: lib/core/widgets/commit_tile.dart
// 📌 AÇIKLAMA: GitHub commit detayını (kısa SHA, mesaj, tarih ve süre aşımı uyarısı)
//              öğretmen inceleme ekranında liste öğesi olarak render eden bileşen.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../utils/date_utils.dart';

/// [CommitTile], bir Git commit'inin SHA özetini ve son teslimden sonra atılıp
/// atılmadığını gösteren görsel karo bileşenidir.
class CommitTile extends StatelessWidget {
  final String sha;
  final String message;
  final DateTime date;
  final bool isAfterDeadline;

  const CommitTile({
    super.key,
    required this.sha,
    required this.message,
    required this.date,
    this.isAfterDeadline = false,
  });

  @override
  Widget build(BuildContext context) {
    final shortSha = sha.length > 7 ? sha.substring(0, 7) : sha;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAfterDeadline ? AppColors.warning.withValues(alpha: 0.5) : AppColors.outline,
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortSha,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  AppDateUtils.formatDateTime(date),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (isAfterDeadline) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Süre Sonrası',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

