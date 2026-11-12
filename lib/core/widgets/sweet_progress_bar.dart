// ==============================================================================
// 📌 DOSYA: lib/core/widgets/sweet_progress_bar.dart
// 📌 AÇIKLAMA: Yüzdelik ilerlemeye göre otomatik renk değiştiren (yeşil, kehribar, kırmızı)
//              ve gradyan dolgulu sevimli ilerleme çubuğu (Sweet Progress Bar).
// ==============================================================================

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// [SweetProgressBar], ödev tamamlama oranı, devamsızlık durumu ve not ortalamasını
/// dinamik gradyan çubuğu ve durum ikonuyla gösterir.
class SweetProgressBar extends StatelessWidget {
  final double progress; // 0.0 ile 1.0 arası
  final String label;
  final String? subtitle;
  final String? mascot;
  final List<Color>? gradientColors;
  final double height;

  const SweetProgressBar({
    super.key,
    required this.progress,
    required this.label,
    this.subtitle,
    this.mascot,
    this.gradientColors,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final percentInt = (clamped * 100).toInt();

    final defaultColors = clamped >= 0.8
        ? [AppColors.primary, AppColors.accent]
        : clamped >= 0.4
            ? [AppColors.secondary, AppColors.warning]
            : [AppColors.error, const Color(0xFFFF9AA2)];

    final colors = gradientColors ?? defaultColors;

    final defaultIcon = clamped >= 1.0
        ? Icons.emoji_events_rounded
        : clamped >= 0.75
            ? Icons.trending_up_rounded
            : clamped >= 0.4
                ? Icons.school_rounded
                : Icons.hourglass_empty_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(defaultIcon, size: 16, color: colors.first),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.first.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '%$percentInt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colors.first,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(height),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * clamped,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(height),
                      boxShadow: [
                        BoxShadow(
                          color: colors.first.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

