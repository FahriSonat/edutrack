// ==============================================================================
// 📌 DOSYA: lib/app/theme/app_spacing.dart
// 📌 AÇIKLAMA: Uygulama genelinde padding, margin ve SizedBox boşluklarının
//              8'lik grid sistemine göre tutarlı olmasını sağlayan aralık sabitleri.
// ==============================================================================

/// [AppSpacing], ekran bileşenleri arasındaki standart boşluk değerlerini tanımlar.
class AppSpacing {
  AppSpacing._();

  /// 4.0 px - Çok dar boşluklar, chip içi ve satır içi öğeler
  static const double xs = 4.0;

  /// 8.0 px - Kompakt liste elemanları ve form içi boşluklar
  static const double sm = 8.0;

  /// 12.0 px - Kartlar arası ve orta ölçekli aralıklar
  static const double md = 12.0;

  /// 16.0 px - Standart sayfa kenar dolgusu ve kart içi padding
  static const double lg = 16.0;

  /// 24.0 px - Bölümler arası geniş boşluklar
  static const double xl = 24.0;

  /// 32.0 px - Sayfa başlıkları ve login formu üst/alt boşlukları
  static const double xxl = 32.0;
}
