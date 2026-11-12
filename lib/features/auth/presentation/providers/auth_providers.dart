// ==============================================================================
// 📌 DOSYA: lib/features/auth/presentation/providers/auth_providers.dart
// 📌 AÇIKLAMA: Kimlik doğrulama, kullanıcı oturumu ve demo modunun Riverpod
//              provider'ları. Oturum açma, çıkış yapma ve profil takibini yönetir.
// ==============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/result.dart';
import '../../../../core/firebase/firebase_providers.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// ==============================================================================
// 📦 1. DEPENDENCY INJECTION (VERİ KAYNAĞI VE REPOSITORY)
// ==============================================================================

/// Auth uzak veri kaynağı provider'ı
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRemoteDataSourceImpl(auth: auth, firestore: firestore);
});

/// Auth repository provider'ı
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

/// Firebase Auth oturum değişikliklerini gerçek zamanlı dinleyen StreamProvider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

// ==============================================================================
// 🎭 2. DEMO KULLANICI YÖNETİMİ (ÇEVRİMDIŞI / TEST MODU)
// ==============================================================================

/// Firebase bağlanmamışken veya prototip testlerinde rol simülasyonu sağlayan notifier
class DemoUserNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void setUser(AppUser? user) => state = user;
}

final demoUserProvider =
    NotifierProvider<DemoUserNotifier, AppUser?>(DemoUserNotifier.new);

// ==============================================================================
// 👤 3. AKTİF KULLANICI PROFİLİ SAĞLAYICI (CURRENT PROFILE)
// ==============================================================================

/// Aktif kullanıcının [AppUser] profilini dinleyen ana provider.
/// Demo moddaysa demo kullanıcıyı, Firebase ile giriş yapılmışsa Firestore profilini döner.
final currentUserProfileProvider = StreamProvider<AppUser?>((ref) {
  final demoUser = ref.watch(demoUserProvider);
  if (demoUser != null) {
    return Stream.value(demoUser);
  }

  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(null);
  }
  final repository = ref.watch(authRepositoryProvider);
  return repository.watchUserProfile(user.uid);
});

// ==============================================================================
// 🎮 4. AUTH KONTROLÖRÜ (GİRİŞ, ÇIKIŞ, ŞİFRE DEĞİŞTİRME)
// ==============================================================================

/// [AuthController], UI tarafından tetiklenen giriş, çıkış ve profil güncelleme
/// eylemlerini yönetir ve işlem durumunu (loading/data/error) tutar.
class AuthController extends Notifier<AsyncValue<AppUser?>> {
  @override
  AsyncValue<AppUser?> build() {
    return const AsyncValue.data(null);
  }

  /// E-posta ve şifre ile Firebase Auth üzerinden giriş yapar
  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signInWithEmailAndPassword(email, password);
    return result.when(
      success: (user) {
        state = AsyncValue.data(user);
        return true;
      },
      failure: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }

  /// Demo rollerden biriyle (Öğrenci, Öğretmen, Admin) anında oturum açar
  void signInAsDemo(UserRole role) {
    state = const AsyncValue.loading();
    final demoUser = switch (role) {
      UserRole.student => const AppUser(
          uid: 'demo_student_1',
          fullName: 'Ahmet Yılmaz (Demo Öğrenci)',
          email: 'ogrenci@edutrack.com',
          role: UserRole.student,
          studentNo: '2024101',
          classId: 'bilgisayar_muh_3',
          githubUsername: 'octocat',
        ),
      UserRole.teacher => const AppUser(
          uid: 'demo_teacher_1',
          fullName: 'Dr. Ayşe Demir (Demo Öğretmen)',
          email: 'ogretmen@edutrack.com',
          role: UserRole.teacher,
          defaultLatePolicy: 'allowLate',
        ),
      UserRole.admin => const AppUser(
          uid: 'demo_admin_1',
          fullName: 'Mehmet Kaya (Demo Yönetici)',
          email: 'admin@edutrack.com',
          role: UserRole.admin,
        ),
    };

    ref.read(demoUserProvider.notifier).setUser(demoUser);
    state = AsyncValue.data(demoUser);
  }

  /// Aktif oturumu kapatır
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    ref.read(demoUserProvider.notifier).setUser(null);
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
    } catch (_) {}
    state = const AsyncValue.data(null);
  }

  /// Şifre güncelleme
  Future<Result<void>> updatePassword(String newPassword) async {
    final repository = ref.read(authRepositoryProvider);
    return repository.updatePassword(newPassword);
  }

  /// Profil güncelleme (Örn: GitHub kullanıcı adı)
  Future<Result<void>> updateProfile(AppUser user) async {
    final demoUser = ref.read(demoUserProvider);
    if (demoUser != null) {
      ref.read(demoUserProvider.notifier).setUser(user);
      return Result.success(null);
    }
    final repository = ref.read(authRepositoryProvider);
    return repository.updateUserProfile(user);
  }
}

/// [AuthController] notifier sağlayıcısı
final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<AppUser?>>(AuthController.new);
