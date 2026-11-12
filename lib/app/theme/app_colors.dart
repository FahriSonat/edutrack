// ==============================================================================
// 📌 DOSYA: lib/app/theme/app_colors.dart
// 📌 AÇIKLAMA: EduTrack uygulamasının Nordic Dark Blue renk paleti ve tasarım tokenları.
//              Kontrastı yüksek, göz yormayan ve modern arayüz standartlarına uygun
//              renk sabitlerini barındırır.
// ==============================================================================

import 'package:flutter/material.dart';

/// [AppColors], uygulamanın tüm görsel bileşenlerinde kullanılan merkezi renk paletidir.
/// Sınıfın doğrudan örneği alınamaz (private constructor).
class AppColors {
  AppColors._();

  // ==========================================================================
  // 🌌 ZEMİN VE YÜZEY RENKLERİ (SURFACE & BACKGROUND)
  // ==========================================================================
  /// Ana sayfa arka plan rengi (Aydınlatılmış Gece Mavisi)
  static const background = Color(0xFF131B2E);

  /// AppBar, BottomNavigationBar ve modal zeminleri
  static const surface = Color(0xFF1A243D);

  /// Standart kart ve panel zemin rengi
  static const surfaceContainer = Color(0xFF233052);

  /// Kapsül, chip ve yüksek kontrastlı iç alan zeminleri
  static const surfaceHigh = Color(0xFF2E3E68);

  /// İkincil hafif koyu zemin
  static const surfaceSubtle = Color(0xFF182238);

  // ==========================================================================
  // ⚡ VURGU VE MARKA RENKLERİ (BRAND ACCENTS)
  // ==========================================================================
  /// Ana marka rengi: Işıltılı Neon Mint Yeşili (Öğrenci, Teslim, Onay)
  static const primary = Color(0xFF00F5A0);
  static const primarySoft = Color(0xFF0D5E46);
  static const onPrimary = Color(0xFF021B13); // Primary üzeri kontrast metin

  /// İkincil marka rengi: Parlak Kehribar Sarısı (Öğretmen, Sınıf, Uyarı)
  static const secondary = Color(0xFFFFB020);
  static const secondarySoft = Color(0xFF5E3F0A);
  static const onSecondary = Color(0xFF1F1202);

  /// Üçüncül renk: Gökyüzü Cyan (Admin, GitHub, Bağlantılar)
  static const accent = Color(0xFF38BDF8);

  /// Ekstra vurgu: Lavanta Moru & Canlı Pembe
  static const violet = Color(0xFFA78BFA);
  static const pink = Color(0xFFF472B6);

  // ==========================================================================
  // ✍️ METİN VE İKON RENKLERİ (TYPOGRAPHY)
  // ==========================================================================
  /// Başlıklar ve birincil metinler (Kristal Beyaz)
  static const onSurface = Color(0xFFFFFFFF);

  /// Gövde metinleri ve etiketler (Çok Açık Gri)
  static const onSurfaceVariant = Color(0xFFE2E8F0);

  /// Açıklamalar ve ikincil bilgiler (Orta Gri)
  static const onSurfaceMuted = Color(0xFFA0AEC0);

  // ==========================================================================
  // 📏 KENARLIK VE ÇİZGİLER (OUTLINE & DIVIDER)
  // ==========================================================================
  /// Belirgin çerçeve ve form konturları
  static const outline = Color(0xFF3E507D);

  /// Yumuşak kart sınır çizgileri
  static const outlineSoft = Color(0xFF2A3A60);

  // ==========================================================================
  // 🚦 DURUM VE GERİ BİLDİRİM RENKLERİ (STATUS)
  // ==========================================================================
  /// Başarılı teslim, zamanında, aktif durum
  static const success = Color(0xFF00F5A0);
  static const successSoft = Color(0xFF0E4F3B);

  /// Yaklaşan son teslim tarihi, gecikme uyarısı
  static const warning = Color(0xFFFFB020);
  static const warningSoft = Color(0xFF573B08);

  /// Süresi geçmiş, hatalı veya silme aksiyonları
  static const error = Color(0xFFFF5C7A);
  static const errorSoft = Color(0xFF5C1020);
}
