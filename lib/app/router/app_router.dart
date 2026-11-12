// ==============================================================================
// 📌 DOSYA: lib/app/router/app_router.dart
// 📌 AÇIKLAMA: GoRouter tabanlı deklaratif sayfa yönlendirme ve güvenlik koruması.
//              Kullanıcının oturum durumu ve rolüne (Admin, Teacher, Student) göre
//              dinamik yönlendirme (Auth Guard / Redirect) kurallarını işletir.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/admin_shell_screen.dart';
import '../../features/home/presentation/screens/student_shell_screen.dart';
import '../../features/home/presentation/screens/teacher_shell_screen.dart';
import '../../features/users/domain/entities/app_user.dart';

/// [appRouterProvider], Auth state akışını ve kullanıcı profilini dinleyerek
/// rotaları koruyan ve yönlendiren [GoRouter] örneğini sağlar.
final appRouterProvider = Provider<GoRouter>((ref) {
  // --- 1. State Dinleyicileri ---
  final authState = ref.watch(authStateChangesProvider);
  final profileState = ref.watch(currentUserProfileProvider);

  return GoRouter(
    initialLocation: '/login',

    // ==========================================================================
    // 🔒 YÖNLENDİRME MUHAFIZI (REDIRECT / AUTH GUARD)
    // ==========================================================================
    redirect: (BuildContext context, GoRouterState state) {
      final hasProfile = profileState.value != null;
      final hasAuth = authState.value != null;
      final isLoggedIn = hasProfile || hasAuth;
      final isLoggingIn = state.matchedLocation == '/login';

      // 1. Oturum Açılmamışsa: Sadece /login rotasına izin ver
      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      // 2. Profil Henüz Yükleniyorsa: Bekle
      final profile = profileState.value;
      if (profile == null) {
        return null;
      }

      // 3. Rol Bazlı Hedef Rota Belirleme (project.md Bölüm 3)
      final targetPath = switch (profile.role) {
        UserRole.admin => '/admin',
        UserRole.teacher => '/teacher',
        UserRole.student => '/student',
      };

      // 4. Giriş Ekranındayken veya Kök Dizindeyken Role Göre Yönlendir
      if (isLoggingIn || state.matchedLocation == '/') {
        return targetPath;
      }

      // 5. Yetkisiz Sayfa Erişim Koruması (Role Guard)
      // Öğrenci /admin veya /teacher sayfasına gitmeye kalkarsa kendi paneline döndürülür
      if (state.matchedLocation.startsWith('/admin') && profile.role != UserRole.admin) {
        return targetPath;
      }
      if (state.matchedLocation.startsWith('/teacher') && profile.role != UserRole.teacher) {
        return targetPath;
      }
      if (state.matchedLocation.startsWith('/student') && profile.role != UserRole.student) {
        return targetPath;
      }

      // İzin verilen rotaya devam et
      return null;
    },

    // ==========================================================================
    // 🗺️ ROTA TANIMLARI
    // ==========================================================================
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentShellScreen(),
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherShellScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminShellScreen(),
      ),
    ],
  );
});
