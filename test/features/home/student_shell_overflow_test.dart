import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:edutrack_app/features/home/presentation/screens/student_shell_screen.dart';
import 'package:edutrack_app/features/users/domain/entities/app_user.dart';

void main() {
  testWidgets('StudentShellScreen renders all tabs without any RenderFlex overflow', (tester) async {
    // 360x640 küçük Android ekranı
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testUser = AppUser(
      uid: 'student-1',
      fullName: 'Ahmet Yılmaz',
      email: 'ahmet@edutrack.edu.tr',
      role: UserRole.student,
      studentNo: '2024101',
      classId: 'bilgisayar_muh_3',
      createdAt: DateTime.now(),
    );

    final container = ProviderContainer(
      overrides: [
        currentUserProfileProvider.overrideWith((ref) => Stream.value(testUser)),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: StudentShellScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Tab 0 (Home) overflowed');

    // 2. Sekme: Ödevlerim
    await tester.tap(find.text('Ödevler'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Tab 1 (Assignments) overflowed');

    // 3. Sekme: Notlarım
    await tester.tap(find.text('Notlar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Tab 2 (Grades) overflowed');

    // 4. Sekme: Program
    await tester.tap(find.text('Program'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Tab 3 (Schedule) overflowed');

    // 5. Sekme: Profil
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Tab 4 (Profile) overflowed');
  });
}
