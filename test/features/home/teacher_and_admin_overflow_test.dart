import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:edutrack_app/features/home/presentation/screens/teacher_shell_screen.dart';
import 'package:edutrack_app/features/home/presentation/screens/admin_shell_screen.dart';
import 'package:edutrack_app/features/users/domain/entities/app_user.dart';

void main() {
  group('Teacher & Admin Shell Overflow Tests on Small Screen (360x640)', () {
    testWidgets('TeacherShellScreen renders all tabs without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final teacher = AppUser(
        uid: 'teacher-1',
        fullName: 'Dr. Ayşe Demir',
        email: 'ayse@edutrack.edu.tr',
        role: UserRole.teacher,
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(teacher)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TeacherShellScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Teacher Tab 0 overflowed');

      // Derslerim
      await tester.tap(find.text('Derslerim'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Teacher Tab 1 overflowed');

      // Ödevler
      await tester.tap(find.text('Ödevler'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Teacher Tab 2 overflowed');

      // Yoklama
      await tester.tap(find.text('Yoklama'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Teacher Tab 3 overflowed');

      // Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Teacher Tab 4 overflowed');
    });

    testWidgets('AdminShellScreen renders all tabs without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final admin = AppUser(
        uid: 'admin-1',
        fullName: 'Sistem Yöneticisi',
        email: 'admin@edutrack.edu.tr',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(admin)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: AdminShellScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Admin Tab 0 overflowed');

      // Kullanıcılar
      await tester.tap(find.text('Kullanıcılar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Admin Tab 1 overflowed');

      // Sınıflar
      await tester.tap(find.text('Sınıflar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Admin Tab 2 overflowed');

      // Dersler
      await tester.tap(find.text('Dersler'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Admin Tab 3 overflowed');

      // Duyurular
      await tester.tap(find.text('Duyurular'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Admin Tab 4 overflowed');
    });
  });
}
