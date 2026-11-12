// ==============================================================================
// 📌 DOSYA: lib/core/error/result.dart
// 📌 AÇIKLAMA: Fonksiyonel programlama yaklaşımıyla başarı ve hata durumlarını
//              tip güvenli (Type-safe) sarmalayan [Result] monadı / deseni.
// ==============================================================================

import 'failure.dart';

/// [Result], bir operasyonun başarılı ([Success]) veya hatalı ([Error])
/// sonuçlandığını gösteren soyut temel sınıftır.
abstract class Result<T> {
  const Result();

  /// Başarılı sonuç örneği oluşturur
  factory Result.success(T data) = Success<T>;

  /// Hatalı sonuç örneği oluşturur
  factory Result.failure(Failure failure) = Error<T>;

  /// Sonuç durumuna göre ilgili callback fonksiyonunu çalıştırır
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  });

  /// İşlemin başarılı olup olmadığını döner
  bool get isSuccess => this is Success<T>;

  /// İşlemin hatalı olup olmadığını döner
  bool get isFailure => this is Error<T>;

  /// Başarı durumundaki veriyi döner (hata varsa null)
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  /// Hata durumundaki nesneyi döner (başarı varsa null)
  Failure? get failureOrNull => this is Error<T> ? (this as Error<T>).failure : null;
}

/// Başarılı işlem sonucu sarmalayıcısı.
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) =>
      success(data);
}

/// Hatalı işlem sonucu sarmalayıcısı.
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) =>
      failure(this.failure);
}
