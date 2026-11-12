// ==============================================================================
// 📌 DOSYA: lib/core/widgets/assignment_ticket_card.dart
// 📌 AÇIKLAMA: Ödev listesinde kullanılan bilet / baloncuk (capsule bubble) tasarımlı
//              yatay ödev kartı. Durum rozeti, ders adı, son teslim sayacı içerir.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../features/assignments/domain/entities/assignment.dart';
import '../../features/assignments/domain/entities/late_policy.dart';
import '../../features/submissions/domain/entities/submission.dart';
import 'bouncy_card.dart';

/// [AssignmentTicketCard], yatay bilet tarzı görsel hiyerarşiyle ödevin
/// teslim durumunu (Açık, Geç, Kapalı, Teslim Edildi) gösterir.
class AssignmentTicketCard extends StatelessWidget {
  final Assignment assignment;
  final Submission? submission;
  final VoidCallback onTap;

  const AssignmentTicketCard({
    super.key,
    required this.assignment,
    this.submission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = assignment.getSubmissionState();
    final isSubmitted = submission != null;

    // Baloncuk Tema Rengi
    final (accentColor, statusIcon) = switch (state) {
      _ when isSubmitted => (AppColors.accent, Icons.check_circle_rounded),
      SubmissionState.open => (AppColors.primary, Icons.assignment_outlined),
      SubmissionState.late => (AppColors.warning, Icons.hourglass_top_rounded),
      SubmissionState.closed => (AppColors.error, Icons.lock_outline_rounded),
    };

    // Süre İlerlemesi
    final totalHours = assignment.dueAt.difference(assignment.createdAt).inHours;
    final remainingHours = assignment.dueAt.difference(DateTime.now()).inHours;
    final progress = totalHours > 0 ? (1.0 - (remainingHours / totalHours)).clamp(0.0, 1.0) : 1.0;

    return BouncyCard(
      onTap: onTap,
      borderRadius: 26,
      color: AppColors.surfaceContainer,
      border: Border.all(
        color: accentColor.withValues(alpha: 0.35),
        width: 1.2,
      ),
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ÜST KAPSÜL SATIRI (Header Capsule Row)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sol: Ders Kapsülü
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.outlineSoft),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      assignment.courseName,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Sağ: Durum Kapsülü (Status Capsule Pill)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isSubmitted
                          ? 'Teslim Edildi'
                          : state == SubmissionState.open
                              ? 'Açık Ödev'
                              : state == SubmissionState.late
                                  ? 'Geç Teslim'
                                  : 'Kapalı',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. İÇ ANA GÖVDE BALONCUĞU (Nested Main Bubble)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineSoft.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  assignment.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 12),

                // İç İlerleme Kapsülü (Mini Progress Capsule)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isSubmitted
                                ? 'Ödev Başarıyla Teslim Edildi'
                                : state == SubmissionState.late
                                    ? 'Geç Teslim Süresinde'
                                    : 'Kalan Süre İlerlemesi',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${((isSubmitted ? 1.0 : progress) * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: isSubmitted ? 1.0 : progress,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceHigh,
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 3. ALT KAPSÜL ADACIĞI (Footer Pills Row)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // GitHub Kapsülü
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.outlineSoft),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.code_rounded, size: 13, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'GitHub',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Dosya Eki Kapsülü
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.outlineSoft),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file_rounded, size: 13, color: AppColors.accent),
                        SizedBox(width: 3),
                        Text(
                          'Dosya Eki',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Kalan Süre Kapsülü
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.outlineSoft),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      AppDateUtils.remainingTimeText(assignment.dueAt),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


