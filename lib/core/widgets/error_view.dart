// ==============================================================================
// 📌 DOSYA: lib/core/widgets/error_view.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Ağ, veri veya işlem hatalarında kullanıcıya gösterilen ortak hata
//           (Error State) arayüz bileşeni.
// 📋 İÇERİK:
//   - Hata ikonu (error_outline_rounded), 'Bir Hata Oluştu' başlığı ve açıklama
//   - Opsiyonel 'Tekrar Dene' butonu ve onRetry geri çağırma tetikleyicisi
// ==============================================================================

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Hata durumlarını bildiren ve kullanıcıya tekrar deneme imkanı sunan bileşen
class ErrorView extends StatelessWidget {
  /// Gösterilecek detaylı hata mesajı
  final String message;

  /// 'Tekrar Dene' butonuna tıklandığında çalışacak fonksiyon (null ise buton gizlenir)
  final VoidCallback? onRetry;

  /// Yeniden deneme butonunun üzerindeki metin (varsayılan: 'Tekrar Dene')
  final String retryButtonText;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryButtonText = 'Tekrar Dene',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bir Hata Oluştu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryButtonText),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceHigh,
                  foregroundColor: AppColors.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
