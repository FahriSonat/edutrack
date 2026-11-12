// ==============================================================================
// 📌 DOSYA: lib/core/utils/validators.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Form alanları (TextFormField) için standart doğrulama (validation)
//           fonksiyonları. E-posta, şifre, boşluk, GitHub URL ve sayı aralığı
//           kontrolleri yapar.
// ==============================================================================

import 'github_url_parser.dart';

/// [Validators], form alanlarında kullanılan tekrar kullanılabilir validasyon mantıklarını sunar.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Zorunlu alan kontrolü
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName boş bırakılamaz.' : 'Bu alan zorunludur.';
    }
    return null;
  }

  /// Geçerli e-posta adresi kontrolü
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur.';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz.';
    }
    return null;
  }

  /// Şifre minimum karakter kontrolü (en az 6 karakter)
  static String? password(String? value, [int minLength = 6]) {
    if (value == null || value.isEmpty) {
      return 'Şifre zorunludur.';
    }
    if (value.length < minLength) {
      return 'Şifre en az $minLength karakter olmalıdır.';
    }
    return null;
  }

  /// GitHub repository URL geçerlilik kontrolü
  static String? githubRepoUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'GitHub repo linki zorunludur.';
    }
    if (!GithubUrlParser.isValid(value)) {
      return 'Geçerli bir GitHub linki giriniz (örn: https://github.com/kullanici/repo).';
    }
    return null;
  }

  /// Belirli bir sayı aralığı kontrolü (örn: Not veya Ceza yüzdesi için 0 - 100)
  static String? numberInRange(
    String? value, {
    int? min,
    int? max,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName zorunludur.' : 'Bu alan zorunludur.';
    }
    final numVal = int.tryParse(value.trim());
    if (numVal == null) {
      return 'Geçerli bir sayı giriniz.';
    }
    if (min != null && numVal < min) {
      return fieldName != null
          ? '$fieldName en az $min olmalıdır.'
          : 'En az $min girilmelidir.';
    }
    if (max != null && numVal > max) {
      return fieldName != null
          ? '$fieldName en fazla $max olabilir.'
          : 'En fazla $max girilebilir.';
    }
    return null;
  }
}
