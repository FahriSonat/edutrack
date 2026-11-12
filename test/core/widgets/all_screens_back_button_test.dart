import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/demo/demo_data.dart';
import 'package:edutrack_app/features/assignments/presentation/screens/create_assignment_screen.dart';
import 'package:edutrack_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:edutrack_app/features/auth/presentation/screens/login_screen.dart';
import 'package:edutrack_app/features/home/presentation/screens/admin_shell_screen.dart';
import 'package:edutrack_app/features/home/presentation/screens/student_shell_screen.dart';
import 'package:edutrack_app/features/home/presentation/screens/teacher_shell_screen.dart';
import 'package:edutrack_app/features/submissions/presentation/screens/submission_review_screen.dart';
import 'package:edutrack_app/features/submissions/presentation/screens/submit_assignment_screen.dart';
import 'package:edutrack_app/features/users/domain/entities/app_user.dart';

void main() {
  group('Back Button (Geri Butonu) Verification on Every Single Screen', () {
    testWidgets('LoginScreen has visible back button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byKey(const Key('login_back_button'));
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });

    testWidgets('AdminShellScreen has back button that navigates tabs then pops/signs out', (tester) async {
      final admin = AppUser(
        uid: 'admin_1',
        fullName: 'Mehmet Kaya',
        email: 'admin@edutrack.com',
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

      // Switch to tab 2
      await tester.tap(find.byKey(const Key('admin_stat_classes')));
      await tester.pumpAndSettle();
      expect(find.text('Sınıf Yönetimi'), findsOneWidget);

      // Back button on tab 2 should return to tab 0
      final backButton = find.byKey(const Key('admin_back_button'));
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      expect(find.text('EduTrack — Yönetici Paneli'), findsOneWidget);
    });

    testWidgets('TeacherShellScreen has back button that navigates tabs then pops/signs out', (tester) async {
      final teacher = AppUser(
        uid: 'teacher_1',
        fullName: 'Dr. Ayşe Demir',
        email: 'ayse@edutrack.com',
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

      // Switch to tab 1
      await tester.tap(find.text('Derslerim'));
      await tester.pumpAndSettle();

      // Tap back button
      final backButton = find.byKey(const Key('teacher_back_button'));
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      expect(find.text('EduTrack — Öğretmen'), findsOneWidget);
    });

    testWidgets('StudentShellScreen has back button that navigates tabs then pops/signs out', (tester) async {
      final student = AppUser(
        uid: 'student_1',
        fullName: 'Ahmet Yılmaz',
        email: 'ahmet@edutrack.com',
        role: UserRole.student,
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(student)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: StudentShellScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to tab 1
      await tester.tap(find.text('Ödevler'));
      await tester.pumpAndSettle();

      // Tap back button
      final backButton = find.byKey(const Key('student_back_button'));
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      expect(find.text('EduTrack — Öğrenci'), findsOneWidget);
    });

    testWidgets('CreateAssignmentScreen has back button and pops', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: CreateAssignmentScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byKey(const Key('create_assignment_back_button'));
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });

    testWidgets('SubmissionReviewScreen has back button and pops', (tester) async {
      final assignment = DemoData.sampleAssignments.first;
      final submission = DemoData.teacherSampleSubmissions.first;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: SubmissionReviewScreen(
              assignment: assignment,
              submission: submission,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byKey(const Key('submission_review_back_button'));
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });

    testWidgets('SubmitAssignmentScreen has back button and pops', (tester) async {
      final student = AppUser(
        uid: 'student_1',
        fullName: 'Ahmet Yılmaz',
        email: 'ahmet@edutrack.com',
        role: UserRole.student,
        githubUsername: 'octocat',
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(student)),
        ],
      );

      final assignment = DemoData.sampleAssignments.first;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: SubmitAssignmentScreen(assignment: assignment),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byKey(const Key('submit_assignment_back_button'));
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });
  });
}

