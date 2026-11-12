import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/app/theme/app_theme.dart';
import 'package:edutrack_app/core/widgets/bouncy_card.dart';
import 'package:edutrack_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:edutrack_app/features/home/presentation/screens/admin_shell_screen.dart';
import 'package:edutrack_app/features/users/domain/entities/app_user.dart';

void main() {
  group('AdminShellScreen Complete & Exhaustive Button / Interaction Tests', () {
    late AppUser testAdmin;

    setUp(() {
      testAdmin = AppUser(
        uid: 'admin_test_1',
        fullName: 'Mehmet Kaya (Sistem Yöneticisi)',
        email: 'admin@edutrack.com',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );
    });

    Widget createWidgetUnderTheme(Widget child, ProviderContainer container) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: child,
        ),
      );
    }

    testWidgets('Hit test on mouse move across entire screen produces zero exceptions', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(testAdmin)),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTheme(const AdminShellScreen(), container));
      await tester.pumpAndSettle();

      // Mouse movements
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(10, 10));
      await tester.pump();

      for (double y = 50; y < 900; y += 40) {
        await gesture.moveTo(Offset(200, y));
        await tester.pump();
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('Tab 0: Bento Stat Cards navigate to respective tabs and filters', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(testAdmin)),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTheme(const AdminShellScreen(), container));
      await tester.pumpAndSettle();

      // Tap Öğrenci stat card -> should navigate to tab 1 (Kullanıcılar)
      await tester.tap(find.byKey(const Key('admin_stat_students')));
      await tester.pumpAndSettle();
      expect(find.text('Kullanıcı Yönetimi'), findsOneWidget);

      // Return to Tab 0
      await tester.tap(find.byIcon(Icons.spa_outlined));
      await tester.pumpAndSettle();
      expect(find.text('EduTrack — Yönetici Paneli'), findsOneWidget);

      // Tap Sınıf stat card -> should navigate to tab 2 (Sınıflar)
      await tester.tap(find.byKey(const Key('admin_stat_classes')));
      await tester.pumpAndSettle();
      expect(find.text('Sınıf Yönetimi'), findsOneWidget);

      // Return to Tab 0
      await tester.tap(find.byIcon(Icons.spa_outlined));
      await tester.pumpAndSettle();

      // Tap Ders stat card -> should navigate to tab 3 (Dersler)
      await tester.tap(find.byKey(const Key('admin_stat_courses')));
      await tester.pumpAndSettle();
      expect(find.text('Ders Yönetimi'), findsOneWidget);
    });

    testWidgets('Tab 0: Quick Action Buttons open and submit all dialogs successfully', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(testAdmin)),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTheme(const AdminShellScreen(), container));
      await tester.pumpAndSettle();

      // 1. Quick Add User
      await tester.tap(find.byKey(const Key('admin_quick_add_user')));
      await tester.pumpAndSettle();
      expect(find.text('Yeni Kullanıcı Oluştur'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('admin_create_user_name')), 'Zeynep Kaya');
      await tester.enterText(find.byKey(const Key('admin_create_user_email')), 'zeynep@edutrack.com');
      await tester.tap(find.byKey(const Key('admin_save_user_button')));
      await tester.pumpAndSettle();
      // Dismiss snackbar
      tester.binding.rootElement?.findAncestorWidgetOfExactType<ScaffoldMessenger>();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 2. Quick Add Class
      await tester.tap(find.byKey(const Key('admin_quick_add_class')));
      await tester.pumpAndSettle();
      expect(find.text('Yeni Sınıf Ekle'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('admin_create_class_name')), 'Yazılım Müh. 2-B');
      await tester.tap(find.byKey(const Key('admin_save_class_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 3. Quick Add Course
      await tester.tap(find.byKey(const Key('admin_quick_add_course')));
      await tester.pumpAndSettle();
      expect(find.text('Yeni Ders Ekle'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('admin_create_course_code')), 'SWE204');
      await tester.enterText(find.byKey(const Key('admin_create_course_name')), 'Yazılım Tasarımı');
      await tester.tap(find.byKey(const Key('admin_save_course_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 4. Quick Add Announcement
      await tester.tap(find.byKey(const Key('admin_quick_add_announcement')));
      await tester.pumpAndSettle();
      expect(find.text('Yeni Duyuru Yayınla'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('admin_create_announcement_title')), 'Final Sınav Takvimi');
      await tester.enterText(find.byKey(const Key('admin_create_announcement_body')), 'Sınav tarihleri web portalında ilan edilmiştir.');
      await tester.tap(find.byKey(const Key('admin_save_announcement_button')));
      await tester.pumpAndSettle();

      // Verify that all 4 created items exist in their respective tabs:
      // Tab 1: Zeynep Kaya
      await tester.tap(find.byKey(const Key('admin_stat_students')));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((w) => w is BouncyCard && find.text('Zeynep Kaya').evaluate().isNotEmpty), findsWidgets);

      // Tab 2: Yazılım Müh. 2-B
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(Icons.meeting_room_outlined)));
      await tester.pumpAndSettle();
      expect(find.text('Yazılım Müh. 2-B'), findsOneWidget);

      // Tab 3: SWE204
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(Icons.class_outlined)));
      await tester.pumpAndSettle();
      expect(find.text('SWE204'), findsOneWidget);

      // Tab 4: Final Sınav Takvimi
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(Icons.campaign_outlined)));
      await tester.pumpAndSettle();
      expect(find.text('Final Sınav Takvimi'), findsOneWidget);
    });

    testWidgets('Tab 1 (Kullanıcılar): Filter, search, add, delete with confirmation', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(testAdmin)),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTheme(const AdminShellScreen(), container));
      await tester.pumpAndSettle();

      // Go to Tab 1
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(Icons.people_outline)));
      await tester.pumpAndSettle();

      // Filter chips test
      await tester.tap(find.byKey(const Key('admin_filter_chip_teacher')));
      await tester.pumpAndSettle();
      expect(find.text('Dr. Ayşe Demir'), findsOneWidget);

      await tester.tap(find.byKey(const Key('admin_filter_chip_all')));
      await tester.pumpAndSettle();

      // Search field test
      await tester.enterText(find.byKey(const Key('admin_user_search_field')), 'Ahmet');
      await tester.pumpAndSettle();
      expect(find.text('Ahmet Yılmaz'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      // Add user via Tab 1 Header button
      await tester.tap(find.byKey(const Key('admin_users_add_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('admin_create_user_name')), 'Deniz Arslan');
      await tester.enterText(find.byKey(const Key('admin_create_user_email')), 'deniz@edutrack.com');
      await tester.tap(find.byKey(const Key('admin_save_user_button')));
      await tester.pumpAndSettle();
      expect(find.text('Deniz Arslan'), findsOneWidget);

      // Delete user test
      final deleteBtn = find.byKey(const Key('admin_delete_user_user_1'));
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Confirmation dialog
      expect(find.text('Kullanıcıyı Sil'), findsOneWidget);
      await tester.tap(find.text('Sil'));
      await tester.pumpAndSettle();

      // Ahmet Yılmaz should be removed from the list
      expect(find.byKey(const Key('admin_user_card_user_1')), findsNothing);
    });

    testWidgets('Tab 2 (Sınıflar): Add and delete class with confirmation', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(testAdmin)),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTheme(const AdminShellScreen(), container));
      await tester.pumpAndSettle();

      // Go to Tab 2
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(Icons.meeting_room_outlined)));
      await tester.pumpAndSettle();
      expect(find.text('Sınıf Yönetimi'), findsOneWidget);

      // Add class via header button
      await tester.tap(find.byKey(const Key('admin_classes_add_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('admin_create_class_name')), 'Elektrik Müh. 1-A');
      await tester.tap(find.byKey(const Key('admin_save_class_button')));
      await tester.pumpAndSettle();
      expect(find.text('Elektrik Müh. 1-A'), findsOneWidget);

      // Delete class
      final deleteClassBtn = find.byKey(const Key('admin_delete_class_bilgisayar_muh_1'));
      expect(deleteClassBtn, findsOneWidget);
      await tester.tap(deleteClassBtn);
      await tester.pumpAndSettle();

      expect(find.text('Sınıfı Sil'), findsOneWidget);
      await tester.tap(find.text('Sil'));
      await tester.pumpAndSettle();

      // Deleted class should no longer exist
      expect(find.byKey(const Key('admin_class_card_bilgisayar_muh_1')), findsNothing);
    });

    testWidgets('Tab 3 (Dersler): Search, add and delete course with confirmation', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(testAdmin)),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTheme(const AdminShellScreen(), container));
      await tester.pumpAndSettle();

      // Go to Tab 3
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(Icons.class_outlined)));
      await tester.pumpAndSettle();
      expect(find.text('Ders Yönetimi'), findsOneWidget);

      // Search course
      await tester.enterText(find.byKey(const Key('admin_course_search_field')), 'CENG301');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('admin_course_card_CENG301')), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      // Add Course
      await tester.tap(find.byKey(const Key('admin_courses_add_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('admin_create_course_code')), 'CENG401');
      await tester.enterText(find.byKey(const Key('admin_create_course_name')), 'Yapay Zeka');
      await tester.tap(find.byKey(const Key('admin_save_course_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('admin_course_card_CENG401')), findsOneWidget);

      // Delete course
      final deleteCourseBtn = find.byKey(const Key('admin_delete_course_CENG301'));
      expect(deleteCourseBtn, findsOneWidget);
      await tester.tap(deleteCourseBtn);
      await tester.pumpAndSettle();

      expect(find.text('Dersi Sil'), findsOneWidget);
      await tester.tap(find.text('Sil'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin_course_card_CENG301')), findsNothing);
    });

    testWidgets('Tab 4 (Duyurular): Add and delete announcement', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(testAdmin)),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTheme(const AdminShellScreen(), container));
      await tester.pumpAndSettle();

      // Go to Tab 4
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(Icons.campaign_outlined)));
      await tester.pumpAndSettle();
      expect(find.text('Duyuru Merkezi'), findsOneWidget);

      // Add announcement via FAB
      final fab = find.byKey(const ValueKey('admin_fab_announcements'));
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('admin_create_announcement_title')), 'Kütüphane Saatleri');
      await tester.enterText(find.byKey(const Key('admin_create_announcement_body')), 'Sınav haftası boyunca 7/24 açıktır.');
      await tester.tap(find.byKey(const Key('admin_save_announcement_button')));
      await tester.pumpAndSettle();
      expect(find.text('Kütüphane Saatleri'), findsOneWidget);

      // Delete announcement
      final deleteAnnouncementBtn = find.byKey(const Key('admin_delete_announcement_0'));
      expect(deleteAnnouncementBtn, findsOneWidget);
      await tester.tap(deleteAnnouncementBtn);
      await tester.pumpAndSettle();

      expect(find.text('Duyuruyu Sil'), findsOneWidget);
      await tester.tap(find.text('Sil'));
      await tester.pumpAndSettle();

      expect(find.text('Kütüphane Saatleri'), findsNothing);
    });
  });
}
