// ==============================================================================
// 📌 DOSYA: lib/core/widgets/assignment_vertical_card.dart
// 📌 AÇIKLAMA: Ana sayfa yatay kaydırmalı (carousel) alanda gösterilen
//              dikey ödev kartı. Büyük yazılı, kompakt ve taşma korumalıdır.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../features/assignments/domain/entities/assignment.dart';
import '../../features/assignments/domain/entities/late_policy.dart';
import '../../features/submissions/domain/entities/submission.dart';
import 'bouncy_card.dart';

/// [AssignmentVerticalCard], öğrenci ve öğretmen ana ekranında ödevleri
/// görsel bir karusel içinde sunmak için tasarlanmıştır.
class AssignmentVerticalCard extends StatelessWidget {
  final Assignment assignment;
  final Submission? submission;
  final VoidCallback onTap;
  final double? width;

  const AssignmentVerticalCard({
    super.key,
    required this.assignment,
    this.submission,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final state = assignment.getSubmissionState();
    final isSubmitted = submission != null;

    final (baseAccentColor, statusIcon, statusText) = switch (state) {
      _ when isSubmitted => (AppColors.accent, Icons.check_circle_rounded, 'Teslim'),
      SubmissionState.open => (AppColors.primary, Icons.assignment_outlined, 'Açık'),
      SubmissionState.late => (AppColors.warning, Icons.hourglass_top_rounded, 'Geç'),
      SubmissionState.closed => (AppColors.error, Icons.lock_outline_rounded, 'Kapalı'),
    };

    final totalHours = assignment.dueAt.difference(assignment.createdAt).inHours;
    final remainingHours = assignment.dueAt.difference(DateTime.now()).inHours;
    final progress = totalHours > 0 ? (1.0 - (remainingHours / totalHours)).clamp(0.0, 1.0) : 1.0;

    // Doldukça renk koyulaşır ve belirginleşir!
    final dynamicAccentColor = isSubmitted
        ? AppColors.accent
        : Color.lerp(baseAccentColor, const Color(0xFF064E3B), progress * 0.45)!;

    return BouncyCard(
      onTap: onTap,
      borderRadius: 16,
      color: AppColors.surfaceContainer,
      border: Border.all(color: dynamicAccentColor.withValues(alpha: 0.5), width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. ÜST: Ders Kapsülü & Durum Rozeti (Büyük, Okunaklı & Asla Taşmaz)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outlineSoft),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            assignment.courseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: dynamicAccentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: dynamicAccentColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: dynamicAccentColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // 2. ORTA: Başlık & Açıklama (Büyük, Kalın & Kristal Okunaklı)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.onSurface,
                    height: 1.18,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  assignment.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // 3. İLERLEME ÇUBUĞU (Belirgin & Büyük Yazılar, Asla Taşmaz)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isSubmitted ? 'Teslim Edildi' : 'Kalan Süre',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${((isSubmitted ? 1.0 : progress) * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: dynamicAccentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: isSubmitted ? 1.0 : progress,
                      minHeight: 4,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(dynamicAccentColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // 4. ALT: Rozetler & Kalan Süre (Net, Okunaklı & Asla Taşmaz)
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.code_rounded, size: 12, color: AppColors.primary),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.attach_file_rounded, size: 12, color: AppColors.accent),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outlineSoft),
                    ),
                    child: Text(
                      AppDateUtils.remainingTimeText(assignment.dueAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
