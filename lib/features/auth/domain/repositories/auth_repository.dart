// ==============================================================================
// 📌 DOSYA: lib/features/auth/domain/repositories/auth_repository.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Kullanıcı kimlik doğrulama, profil yönetimi ve yönetici kullanıcı açma
//           operasyonlarını soyutlayan domain repository sözleşmesi.
// 📋 İŞLEVLER:
//   - authStateChanges: Firebase oturum durumu değişim akışı
//   - currentFirebaseUser: Aktif Firebase Auth kullanıcısı
//   - signInWithEmailAndPassword: E-posta ve şifre ile giriş
//   - signOut: Oturumu kapatma
//   - updatePassword: Şifre güncelleme
//   - getUserProfile / watchUserProfile: Kullanıcı rol ve profil bilgilerini alma/izleme
//   - createUserAsAdmin: Yöneticinin ana oturumu düşmeden yeni kullanıcı kaydetmesi
// ==============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/result.dart';
import '../../../users/domain/entities/app_user.dart';

/// Kimlik doğrulama ve kullanıcı yetkilendirme soyut arayüzü.
abstract class AuthRepository {
  /// Firebase oturum değişikliklerini anlık dinleyen akış
  Stream<User?> authStateChanges();

  /// Anlık aktif Firebase Auth nesnesi
  User? get currentFirebaseUser;

  /// E-posta ve parola ile oturum açar
  Future<Result<AppUser>> signInWithEmailAndPassword(String email, String password);

  /// Oturumu sonlandırır
  Future<Result<void>> signOut();

  /// Mevcut kullanıcının şifresini yeniler
  Future<Result<void>> updatePassword(String newPassword);

  /// UID üzerinden kullanıcı profilini tek seferlik getirir
  Future<Result<AppUser>> getUserProfile(String uid);

  /// Kullanıcı profilindeki değişiklikleri anlık izleyen akış
  Stream<AppUser?> watchUserProfile(String uid);

  /// Kullanıcı profil bilgilerini günceller
  Future<Result<void>> updateUserProfile(AppUser user);

  /// Yönetici rolüyle yeni bir eğitmen veya öğrenci hesabı açar
  Future<Result<String>> createUserAsAdmin({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? studentNo,
    String? classId,
  });
}
