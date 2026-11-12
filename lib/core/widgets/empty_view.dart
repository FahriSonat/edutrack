// ==============================================================================
// 📌 DOSYA: lib/core/widgets/empty_view.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Liste veya ekranlarda veri bulunamadığında gösterilen ortak boş durum
//           (Empty State) arayüz bileşeni.
// 📋 İÇERİK:
//   - Özelleştirilebilir ikon, başlık, alt açıklama ve isteğe bağlı eylem butonu
//   - Material 3 Koyu Mavi tasarım sistemine uygun renk ve tipografi uyumu
// ==============================================================================

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Boş veri durumlarını kullanıcı dostu bir şekilde görselleştiren bileşen
class EmptyView extends StatelessWidget {
  /// Ana başlık metni (örn: "Henüz ödev bulunmuyor")
  final String title;

  /// Açıklayıcı alt metin (isteğe bağlı)
  final String? subtitle;

  /// Durumu temsil eden simge (varsayılan: Icons.inbox_outlined)
  final IconData icon;

  /// Kullanıcıyı harekete geçirecek buton veya özel widget (örn: Yenile, Ödev Ekle)
  final Widget? action;

  const EmptyView({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
