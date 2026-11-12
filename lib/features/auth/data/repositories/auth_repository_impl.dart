// ==============================================================================
// 📌 DOSYA: lib/features/auth/data/repositories/auth_repository_impl.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: [AuthRepository] domain arayüzünün somut implementasyonu.
// 📋 İŞLEVLER:
//   - RemoteDataSource'tan gelen ham verileri ve istisnaları yakalamak
//   - Hata fırlatmak yerine [Result.success] ve [Result.failure] döndürerek
//     fonksiyonel hata yönetimini garantilemek
//   - Clean Architecture katman ayrımını korumak
// ==============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Kimlik doğrulama veri akışını yöneten repository uygulaması
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  /// Oturum durumu değişikliklerini iletir
  @override
  Stream<User?> authStateChanges() => remoteDataSource.authStateChanges();

  /// Anlık aktif kullanıcıyı döner
  @override
  User? get currentFirebaseUser => remoteDataSource.currentFirebaseUser;

  /// E-posta ve şifre ile giriş denemesi yapar; sonucu Result içinde döner
  @override
  Future<Result<AppUser>> signInWithEmailAndPassword(String email, String password) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(email, password);
      return Result.success(user);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Giriş işlemi başarısız: $e'));
    }
  }

  /// Oturumu kapatır
  @override
  Future<Result<void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure(message: 'Çıkış yapılamadı: $e'));
    }
  }

  /// Şifre güncelleme isteğini iletir
  @override
  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
      return Result.success(null);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Şifre değiştirilemedi: $e'));
    }
  }

  /// Kullanıcı profil bilgilerini tekil olarak çeker
  @override
  Future<Result<AppUser>> getUserProfile(String uid) async {
    try {
      final profile = await remoteDataSource.getUserProfile(uid);
      return Result.success(profile);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Profil yüklenemedi: $e'));
    }
  }

  /// Kullanıcı profil verisini anlık olarak dinler
  @override
  Stream<AppUser?> watchUserProfile(String uid) {
    return remoteDataSource.watchUserProfile(uid);
  }

  /// Kullanıcı profilini günceller
  @override
  Future<Result<void>> updateUserProfile(AppUser user) async {
    try {
      await remoteDataSource.updateUserProfile(user);
      return Result.success(null);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Profil güncellenemedi: $e'));
    }
  }

  /// Yönetici rolüyle yeni kullanıcı oluşturur
  @override
  Future<Result<String>> createUserAsAdmin({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? studentNo,
    String? classId,
  }) async {
    try {
      final uid = await remoteDataSource.createUserAsAdmin(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        studentNo: studentNo,
        classId: classId,
      );
      return Result.success(uid);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Kullanıcı oluşturulamadı: $e'));
    }
  }
}
