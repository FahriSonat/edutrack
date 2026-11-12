// ==============================================================================
// 📌 DOSYA: lib/core/widgets/deadline_badge.dart
// 📌 AÇIKLAMA: Son teslim süresinin kalan miktarını renk kodlu (Kırmızı: Doldu,
//              Sarı: <24s, Gri/Yeşil: Normal) rozet (badge) olarak gösteren bileşen.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../utils/date_utils.dart';

/// [DeadlineBadge], kalan süreyi dinamik renk ve saat/dakika metniyle sunar.
class DeadlineBadge extends StatelessWidget {
  final DateTime deadline;
  final DateTime? now;

  const DeadlineBadge({
    super.key,
    required this.deadline,
    this.now,
  });

  @override
  Widget build(BuildContext context) {
    final current = now ?? DateTime.now();
    final isExpired = deadline.isBefore(current);
    final isWithin24Hours = AppDateUtils.isDueWithin24Hours(deadline, current);

    final color = isExpired
        ? AppColors.error
        : isWithin24Hours
            ? AppColors.warning
            : AppColors.onSurfaceVariant;

    final text = AppDateUtils.remainingTimeText(deadline, current);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.alarm_off_rounded : Icons.access_time_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

