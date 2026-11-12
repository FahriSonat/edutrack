// ==============================================================================
// 📌 DOSYA: lib/features/auth/data/datasources/auth_remote_datasource.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Firebase Authentication ve Cloud Firestore servisleriyle doğrudan konuşan
//           uzak veri kaynağı (Remote Data Source) implementasyonu.
// 📋 İŞLEVLER:
//   - Firebase Auth oturum açma, şifre güncelleme, çıkış yapma
//   - Firestore `users/{uid}` koleksiyonundan profil okuma / yazma / izleme
//   - Admin tarafından ikincil FirebaseApp (`Firebase.initializeApp(name: ...)`)
//     üzerinden ana yönetici oturumu düşmeden yeni kullanıcı hesabı açma
//   - Firebase istisnalarını kullanıcı dostu Türkçe [Failure] nesnelerine dönüştürme
// ==============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/firebase/collections.dart';
import '../../../users/domain/entities/app_user.dart';

/// Kimlik doğrulama veri kaynağı sözleşmesi
abstract class AuthRemoteDataSource {
  Stream<User?> authStateChanges();
  User? get currentFirebaseUser;
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> updatePassword(String newPassword);
  Future<AppUser> getUserProfile(String uid);
  Stream<AppUser?> watchUserProfile(String uid);
  Future<void> updateUserProfile(AppUser user);
  Future<String> createUserAsAdmin({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? studentNo,
    String? classId,
  });
}

/// Firebase servislerini kullanarak [AuthRemoteDataSource] arayüzünü uygulayan sınıf
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.auth,
    required this.firestore,
  });

  /// Kullanıcı oturum durumunun anlık akışı
  @override
  Stream<User?> authStateChanges() => auth.authStateChanges();

  /// Mevcut oturum açmış Firebase kullanıcısı
  @override
  User? get currentFirebaseUser => auth.currentUser;

  /// E-posta ve şifre ile giriş yapar ve ardından kullanıcının Firestore profilini çeker
  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      return await getUserProfile(uid);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'user-not-found' => 'Kullanıcı bulunamadı.',
        'wrong-password' => 'Hatalı şifre girdiniz.',
        'invalid-email' => 'Geçersiz e-posta adresi.',
        'user-disabled' => 'Bu kullanıcı hesabı devre dışı bırakılmış.',
        'invalid-credential' => 'E-posta veya şifre hatalı.',
        _ => 'Giriş yapılamadı: ${e.message ?? e.code}',
      };
      throw Failure(message: message, code: e.code, originalError: e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(message: 'Beklenmeyen bir hata oluştu: $e');
    }
  }

  /// Aktif oturumu sonlandırır
  @override
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Oturumu açık olan kullanıcının şifresini değiştirir
  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw const Failure(message: 'Oturum bulunamadı.');
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'weak-password' => 'Şifre çok zayıf. Daha güçlü bir şifre seçiniz.',
        'requires-recent-login' => 'Güvenlik nedeniyle şifre değiştirmek için tekrar giriş yapmanız gerekmektedir.',
        _ => 'Şifre güncellenemedi: ${e.message ?? e.code}',
      };
      throw Failure(message: message, code: e.code, originalError: e);
    }
  }

  /// Firestore `users/{uid}` yolundan profil verisini çeker
  @override
  Future<AppUser> getUserProfile(String uid) async {
    try {
      final doc = await firestore.collection(Collections.users).doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        throw const Failure(message: 'Kullanıcı profil verisi bulunamadı.');
      }
      return AppUser.fromMap(doc.data()!, uid);
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(message: 'Kullanıcı profili alınamadı: $e');
    }
  }

  /// Firestore `users/{uid}` dökümanını anlık dinler
  @override
  Stream<AppUser?> watchUserProfile(String uid) {
    return firestore.collection(Collections.users).doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!, uid);
    });
  }

  /// Kullanıcı profil bilgilerini Firestore üzerinde günceller
  @override
  Future<void> updateUserProfile(AppUser user) async {
    try {
      await firestore.collection(Collections.users).doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Failure(message: 'Profil güncellenemedi: $e');
    }
  }

  /// Admin yetkisiyle yeni kullanıcı açar.
  /// ⚠️ Önemli: Ana oturumun düşmesini önlemek için geçici ikincil bir [FirebaseApp]
  /// örneği başlatılır, kullanıcı oluşturulup çıkış yapılır ve ardından silinir.
  @override
  Future<String> createUserAsAdmin({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? studentNo,
    String? classId,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'admin-create-user-${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      await secondaryAuth.signOut();

      // Ana Firestore bağlantısı ile users/{uid} dökümanını kaydet
      final appUser = AppUser(
        uid: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        role: role,
        studentNo: studentNo?.trim(),
        classId: classId,
        createdAt: DateTime.now(),
      );

      await firestore.collection(Collections.users).doc(uid).set({
        ...appUser.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return uid;
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'email-already-in-use' => 'Bu e-posta adresi ile kayıtlı bir hesap zaten var.',
        'invalid-email' => 'Geçersiz e-posta adresi formatı.',
        'weak-password' => 'Şifre çok zayıf.',
        _ => 'Kullanıcı oluşturulamadı: ${e.message ?? e.code}',
      };
      throw Failure(message: message, code: e.code, originalError: e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(message: 'Kullanıcı oluşturulurken bir hata oluştu: $e');
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }
}
