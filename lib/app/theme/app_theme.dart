// ==============================================================================
// 📌 DOSYA: lib/app/theme/app_theme.dart
// 📌 AÇIKLAMA: Material 3 tabanlı merkezi tema yapılandırması.
//              Tipografi (Google Fonts Plus Jakarta Sans), Form alanları, Kartlar,
//              Butonlar, AppBar ve NavigationBar stillerini tek bir noktadan yönetir.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// [AppTheme], Material 3 koyu temasını yapılandıran fabrika sınıfıdır.
class AppTheme {
  AppTheme._();

  /// Uygulamanın ana koyu tema tanımı ([ThemeData]).
  static ThemeData get dark {
    // ==========================================================================
    // 🎨 1. MATERIAL 3 RENK ŞEMASI (COLOR SCHEME)
    // ==========================================================================
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      onError: Colors.black,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceHigh,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    // ==========================================================================
    // ✍️ 2. TİPOGRAFİ (PLUS JAKARTA SANS)
    // ==========================================================================
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: AppColors.onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.onSurface,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.onSurface,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.onSurface,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      ),
    );

    // ==========================================================================
    // 🛠️ 3. BİLEŞEN TEMA ÖZELLEŞTİRMELERİ
    // ==========================================================================
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,

      // --- Üst Bar (AppBar) Teması ---
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),

      // --- Kart (Card) Teması ---
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.outlineSoft, width: 0.8),
        ),
      ),

      // --- Form Girdi Alanları (Input Decoration) Teması ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHigh,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outlineSoft, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outlineSoft, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
      ),

      // --- Dolgulu Buton (FilledButton) Teması ---
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      // --- Çerçeveli Buton (OutlinedButton) Teması ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: AppColors.outline, width: 1.2),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // --- Alt Navigasyon Çubuğu (NavigationBar) Teması ---
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            );
          }
          return GoogleFonts.plusJakartaSans(
            color: AppColors.onSurfaceMuted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),

      // --- Çip (Chip) Teması ---
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),

      // --- Ayırıcı Çizgi (Divider) Teması ---
      dividerTheme: const DividerThemeData(color: AppColors.outlineSoft, thickness: 0.8),
    );
  }
}
