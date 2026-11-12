import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edutrack_app/features/assignments/presentation/screens/create_assignment_screen.dart';
import 'package:edutrack_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:edutrack_app/features/users/domain/entities/app_user.dart';

void main() {
  testWidgets('CreateAssignmentScreen pump and interaction test', (tester) async {
    final teacher = AppUser(
      uid: 'demo_teacher_1',
      email: 'teacher@edutrack.edu.tr',
      fullName: 'Doç. Dr. Ayşe Demir',
      role: UserRole.teacher,
      defaultLatePolicy: 'allowLate',
    );

    final container = ProviderContainer(
      overrides: [
        currentUserProfileProvider.overrideWith((ref) => Stream.value(teacher)),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: CreateAssignmentScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Tap on dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Select an item
    await tester.tap(find.text('Yazılım Mimarisi ve Tasarım Desenleri').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Switch late policy
    await tester.tap(find.text('Kapalı'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Geç Teslime İzin Ver'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
