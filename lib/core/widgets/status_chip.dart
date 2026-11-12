// ==============================================================================
// 📌 DOSYA: lib/core/widgets/status_chip.dart
// 📌 AÇIKLAMA: Ödev ve teslim durumlarını (Açık, Teslim Edildi, Geç Teslim, Kapalı, Notlandı)
//              ikonlu ve renkli etiket (chip) olarak gösteren görsel bileşen.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Ödev durum türleri
enum StatusType {
  open,
  submitted,
  lateSubmission,
  closed,
  graded,
}

/// [StatusChip], verilen duruma göre uygun renk, metin ve ikon kombinasyonunu render eder.
class StatusChip extends StatelessWidget {
  final StatusType status;
  final String? customLabel;

  const StatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      StatusType.open => ('Açık', AppColors.primary, Icons.schedule_rounded),
      StatusType.submitted => ('Teslim Edildi', AppColors.success, Icons.check_circle_outline_rounded),
      StatusType.lateSubmission => ('Geç Teslim', AppColors.warning, Icons.warning_amber_rounded),
      StatusType.closed => ('Kapalı', AppColors.error, Icons.lock_outline_rounded),
      StatusType.graded => ('Notlandı', AppColors.secondary, Icons.grade_rounded),
    };

    final displayText = customLabel ?? label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            displayText,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

