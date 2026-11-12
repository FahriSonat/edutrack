// ==============================================================================
// 📌 DOSYA: lib/core/error/failure.dart
// 📌 AÇIKLAMA: Uygulama genelinde oluşan veri ve ağ hatalarını temsil eden sınıf.
//              Exception fırlatmak yerine hatayı anlamlı bir nesneye dönüştürür.
// ==============================================================================

/// [Failure], veri kaynağı (Firestore, Auth, Dio vb.) katmanında oluşan
/// hataları standart bir biçimde Domain ve UI katmanına taşır.
class Failure {
  /// Kullanıcıya veya loglara gösterilecek açıklayıcı hata mesajı
  final String message;

  /// Hata kodu (örn: 'user-not-found', 'permission-denied')
  final String? code;

  /// Yakalanan orijinal ham istisna nesnesi
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}
