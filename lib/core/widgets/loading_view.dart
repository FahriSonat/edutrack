// ==============================================================================
// 📌 DOSYA: lib/core/widgets/loading_view.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Asenkron veri yüklemelerinde ve işlemler sürerken gösterilen ortak yükleme
//           (Loading State) arayüz bileşeni.
// 📋 İÇERİK:
//   - Marka rengine uygun CircularProgressIndicator
//   - İsteğe bağlı bilgilendirici durum mesajı (message)
// ==============================================================================

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Sayfa veya modül içi yükleme animasyonunu standartlaştıran bileşen
class LoadingView extends StatelessWidget {
  /// İsteğe bağlı gösterilecek yükleme açıklaması (örn: "Ödevler yükleniyor...")
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
