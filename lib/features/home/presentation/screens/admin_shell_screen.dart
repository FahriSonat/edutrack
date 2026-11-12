// ==============================================================================
// 📌 DOSYA: lib/features/home/presentation/screens/admin_shell_screen.dart
// 📌 AÇIKLAMA: Sistem Yöneticisi (Admin) ana kontrol kabuk (shell) ekranı.
//              5 ana yönetim modülü içerir:
//              1. Özet / Dashboard (Bento grid istatistikleri, 4 hızlı yönetim butonu,
//                 altyapı sağlık monitörü ve son işlem günlüğü)
//              2. Kullanıcı Yönetimi (Rol filtreli/aramalı kullanıcı listesi, ekleme & silme)
//              3. Sınıf Yönetimi (Düzey ve öğrenci kontenjanlı şube yönetimi)
//              4. Ders Yönetimi (Ders kodu, AKTS kredisi ve öğretmen atama yönetimi)
//              5. Duyuru Merkezi (Genel ve role özel okul duyuruları yayınlama)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/demo/demo_data.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/bouncy_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../users/domain/entities/app_user.dart';

/// [AdminShellScreen], yönetici yetkilerine sahip kullanıcılara tam OBS kontrolü sunar.
class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  int _currentIndex = 0;
  String _userRoleFilter = 'all';
  String _userSearchQuery = '';
  String _courseSearchQuery = '';

  final TextEditingController _userSearchCtrl = TextEditingController();
  final TextEditingController _courseSearchCtrl = TextEditingController();

  late List<AppUser> _users;
  late List<Map<String, dynamic>> _classes;
  late List<Map<String, dynamic>> _courses;
  late List<Map<String, dynamic>> _announcements;

  final List<String> _systemLogs = [
    'Sistem yöneticisi Mehmet Kaya başarıyla oturum açtı.',
    'Cloud Firestore koleksiyon kuralları doğrulandı.',
    'GitHub REST API entegrasyonu hazır (60 req/saat).',
    '3 adet aktif ders dönemi başlatıldı.',
  ];

  @override
  void initState() {
    super.initState();
    _users = List.from(DemoData.sampleUsers);
    _classes = List.from(DemoData.sampleClasses);
    _courses = [
      {'code': 'CENG301', 'name': 'Mobil Uygulama Geliştirme', 'teacher': 'Dr. Ayşe Demir', 'credits': 4},
      {'code': 'CENG302', 'name': 'Yazılım Mimarisi', 'teacher': 'Doç. Dr. Serkan Çelik', 'credits': 3},
      {'code': 'CENG303', 'name': 'Veritabanı Sistemleri', 'teacher': 'Prof. Dr. Hakan Erdem', 'credits': 3},
      {'code': 'CENG304', 'name': 'Bilgisayar Ağları', 'teacher': 'Dr. Murat Şahin', 'credits': 3},
    ];
    _announcements = List.from(DemoData.sampleAnnouncements);
  }

  @override
  void dispose() {
    _userSearchCtrl.dispose();
    _courseSearchCtrl.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _systemLogs.insert(0, message);
    });
  }

  // --- 1. KULLANICI OLUŞTURMA DİYALOĞU ---
  void _showCreateUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: '123456');
    final studentNoCtrl = TextEditingController();
    UserRole selectedRole = UserRole.student;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.person_add_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Yeni Kullanıcı Oluştur', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('admin_create_user_name'),
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Ad Soyad', prefixIcon: Icon(Icons.badge_outlined)),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  key: const Key('admin_create_user_email'),
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  key: const Key('admin_create_user_pass'),
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'Geçici Şifre', prefixIcon: Icon(Icons.lock_outline_rounded)),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<UserRole>(
                  key: const Key('admin_create_user_role'),
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Kullanıcı Rolü', prefixIcon: Icon(Icons.security_outlined)),
                  items: const [
                    DropdownMenuItem(value: UserRole.student, child: Text('Öğrenci')),
                    DropdownMenuItem(value: UserRole.teacher, child: Text('Öğretmen')),
                    DropdownMenuItem(value: UserRole.admin, child: Text('Yönetici')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
                if (selectedRole == UserRole.student) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    key: const Key('admin_create_user_studentno'),
                    controller: studentNoCtrl,
                    decoration: const InputDecoration(labelText: 'Öğrenci No (örn. 2024105)', prefixIcon: Icon(Icons.numbers_rounded)),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              key: const Key('admin_save_user_button'),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty && emailCtrl.text.trim().isNotEmpty) {
                  final newUser = AppUser(
                    uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
                    fullName: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    role: selectedRole,
                    studentNo: studentNoCtrl.text.trim().isNotEmpty ? studentNoCtrl.text.trim() : null,
                    createdAt: DateTime.now(),
                  );
                  setState(() {
                    _users.insert(0, newUser);
                  });
                  _addLog('Yeni kullanıcı eklendi: ${newUser.fullName} (${selectedRole.name})');
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${newUser.fullName} kullanıcısı sisteme eklendi!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Kullanıcıyı Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. SINIF OLUŞTURMA DİYALOĞU ---
  void _showCreateClassDialog() {
    final nameCtrl = TextEditingController();
    final gradeCtrl = TextEditingController(text: '1');
    final countCtrl = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.meeting_room_rounded, color: AppColors.secondary),
            SizedBox(width: 8),
            Text('Yeni Sınıf Ekle', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('admin_create_class_name'),
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Sınıf Adı (örn. Bilgisayar Müh. 1-A)', prefixIcon: Icon(Icons.school_outlined)),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('admin_create_class_grade'),
                controller: gradeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sınıf Düzeyi (1-4)', prefixIcon: Icon(Icons.grade_outlined)),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('admin_create_class_count'),
                controller: countCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Öğrenci Sayısı / Kapasite', prefixIcon: Icon(Icons.people_outline)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            key: const Key('admin_save_class_button'),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final newClass = {
                  'id': 'class_${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameCtrl.text.trim(),
                  'gradeLevel': int.tryParse(gradeCtrl.text.trim()) ?? 1,
                  'studentCount': int.tryParse(countCtrl.text.trim()) ?? 30,
                };
                setState(() {
                  _classes.insert(0, newClass);
                });
                _addLog('Yeni sınıf eklendi: ${newClass['name']}');
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${newClass['name']} sınıfı başarıyla oluşturuldu!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Sınıfı Kaydet'),
          ),
        ],
      ),
    );
  }

  // --- 3. DERS OLUŞTURMA DİYALOĞU ---
  void _showCreateCourseDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final teacherCtrl = TextEditingController(text: 'Dr. Ayşe Demir');
    final creditsCtrl = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.menu_book_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Yeni Ders Ekle', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('admin_create_course_code'),
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Ders Kodu (örn. CENG305)', prefixIcon: Icon(Icons.code_rounded)),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('admin_create_course_name'),
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Ders Adı', prefixIcon: Icon(Icons.book_outlined)),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('admin_create_course_teacher'),
                controller: teacherCtrl,
                decoration: const InputDecoration(labelText: 'Öğretim Görevlisi', prefixIcon: Icon(Icons.person_outline_rounded)),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('admin_create_course_credits'),
                controller: creditsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kredi / AKTS', prefixIcon: Icon(Icons.grade_outlined)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            key: const Key('admin_save_course_button'),
            onPressed: () {
              if (codeCtrl.text.trim().isNotEmpty && nameCtrl.text.trim().isNotEmpty) {
                final newCourse = {
                  'code': codeCtrl.text.trim().toUpperCase(),
                  'name': nameCtrl.text.trim(),
                  'teacher': teacherCtrl.text.trim(),
                  'credits': int.tryParse(creditsCtrl.text.trim()) ?? 3,
                };
                setState(() {
                  _courses.insert(0, newCourse);
                });
                _addLog('Yeni ders eklendi: ${newCourse['code']} - ${newCourse['name']}');
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${newCourse['name']} dersi başarıyla eklendi!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Dersi Kaydet'),
          ),
        ],
      ),
    );
  }

  // --- 4. DUYURU OLUŞTURMA DİYALOĞU ---
  void _showAddAnnouncementDialog() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Yeni Duyuru Yayınla', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('admin_create_announcement_title'),
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Duyuru Başlığı', prefixIcon: Icon(Icons.title_rounded)),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('admin_create_announcement_body'),
                controller: bodyCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Duyuru İçeriği', prefixIcon: Icon(Icons.text_snippet_outlined)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            key: const Key('admin_save_announcement_button'),
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty && bodyCtrl.text.trim().isNotEmpty) {
                final newAnnouncement = {
                  'title': titleCtrl.text.trim(),
                  'body': bodyCtrl.text.trim(),
                  'author': 'Mehmet Kaya (Sistem Yöneticisi)',
                  'date': DateTime.now(),
                };
                setState(() {
                  _announcements.insert(0, newAnnouncement);
                });
                _addLog('Yeni duyuru yayınlandı: ${newAnnouncement['title']}');
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Duyuru tüm kullanıcılara başarıyla yayınlandı!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Yayınla'),
          ),
        ],
      ),
    );
  }

  // --- ONAY İLE SİLME DİYALOĞU ---
  void _confirmDelete({required String title, required String message, required VoidCallback onConfirmed}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirmed();
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('admin_back_button'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Geri',
          onPressed: () {
            if (_currentIndex != 0) {
              setState(() => _currentIndex = 0);
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              ref.read(authControllerProvider.notifier).signOut();
            }
          },
        ),
        title: Text(
          switch (_currentIndex) {
            0 => 'EduTrack — Yönetici Paneli',
            1 => 'Kullanıcı Yönetimi',
            2 => 'Sınıf Yönetimi',
            3 => 'Ders Yönetimi',
            _ => 'Duyuru Merkezi',
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, size: 14, color: AppColors.accent),
                SizedBox(width: 4),
                Text('Admin', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            key: const Key('admin_logout_button'),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Çıkış Yap',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Kullanıcı bulunamadı'));
          }
          return IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(user),
              _buildUsersTab(),
              _buildClassesTab(),
              _buildCoursesTab(),
              _buildAnnouncementsTab(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Hata: $err')),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa_rounded),
            label: 'Özet',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Kullanıcılar',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(Icons.meeting_room_rounded),
            label: 'Sınıflar',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_rounded),
            label: 'Dersler',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'Duyurular',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    return switch (_currentIndex) {
      1 => FloatingActionButton.extended(
          key: const ValueKey('admin_fab_users'),
          onPressed: _showCreateUserDialog,
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Kullanıcı Ekle', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
        ),
      2 => FloatingActionButton.extended(
          key: const ValueKey('admin_fab_classes'),
          onPressed: _showCreateClassDialog,
          icon: const Icon(Icons.add_home_work_rounded),
          label: const Text('Sınıf Ekle', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
        ),
      3 => FloatingActionButton.extended(
          key: const ValueKey('admin_fab_courses'),
          onPressed: _showCreateCourseDialog,
          icon: const Icon(Icons.post_add_rounded),
          label: const Text('Ders Ekle', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
      4 => FloatingActionButton.extended(
          key: const ValueKey('admin_fab_announcements'),
          onPressed: _showAddAnnouncementDialog,
          icon: const Icon(Icons.campaign_rounded),
          label: const Text('Yeni Duyuru', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
        ),
      _ => null,
    };
  }

  // ==========================================
  // 1. ÖZET (DASHBOARD) TAB
  // ==========================================
  Widget _buildHomeTab(AppUser user) {
    final studentCount = _users.where((u) => u.role == UserRole.student).length;
    final teacherCount = _users.where((u) => u.role == UserRole.teacher).length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Admin Karşılama Kartı
        BouncyCard(
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.admin_panel_settings_rounded, size: 28, color: AppColors.onPrimary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SİSTEM YÖNETİCİSİ',
                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Text(
                      'EduTrack OBS Admin • Tam Yetki Modu',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Sayaçlar (Bento Grid) - Tıklanabilir ve ilgili sekmelere yönlendirir
        Row(
          children: [
            Expanded(
              child: BouncyCard(
                key: const Key('admin_stat_students'),
                color: AppColors.surfaceHigh,
                margin: const EdgeInsets.only(right: 4, bottom: 8),
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () {
                  setState(() {
                    _userRoleFilter = 'student';
                    _currentIndex = 1;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.school_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(height: 6),
                    Text('$studentCount', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const Text('Öğrenci', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BouncyCard(
                key: const Key('admin_stat_teachers'),
                color: AppColors.surfaceHigh,
                margin: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () {
                  setState(() {
                    _userRoleFilter = 'teacher';
                    _currentIndex = 1;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.secondary),
                    const SizedBox(height: 6),
                    Text('$teacherCount', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                    const Text('Öğretmen', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BouncyCard(
                key: const Key('admin_stat_classes'),
                color: AppColors.surfaceHigh,
                margin: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => setState(() => _currentIndex = 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.meeting_room_outlined, size: 18, color: AppColors.accent),
                    const SizedBox(height: 6),
                    Text('${_classes.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent)),
                    const Text('Sınıf', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BouncyCard(
                key: const Key('admin_stat_courses'),
                color: AppColors.surfaceHigh,
                margin: const EdgeInsets.only(left: 4, bottom: 8),
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => setState(() => _currentIndex = 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.menu_book_outlined, size: 18, color: Color(0xFF6EE7B7)),
                    const SizedBox(height: 6),
                    Text('${_courses.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF6EE7B7))),
                    const Text('Ders', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // Hızlı Yönetim Aksiyonları Butonları (4 Aksiyon)
        Text('Hızlı Yönetim Aksiyonları', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                key: const Key('admin_quick_add_user'),
                onPressed: _showCreateUserDialog,
                icon: const Icon(Icons.person_add_rounded, size: 17),
                label: const Text('Kullanıcı', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: FilledButton.tonalIcon(
                key: const Key('admin_quick_add_class'),
                onPressed: _showCreateClassDialog,
                icon: const Icon(Icons.meeting_room_rounded, size: 17),
                label: const Text('Sınıf Ekle', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                key: const Key('admin_quick_add_course'),
                onPressed: _showCreateCourseDialog,
                icon: const Icon(Icons.book_rounded, size: 17),
                label: const Text('Ders Ekle', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: FilledButton.tonalIcon(
                key: const Key('admin_quick_add_announcement'),
                onPressed: _showAddAnnouncementDialog,
                icon: const Icon(Icons.campaign_rounded, size: 17),
                label: const Text('Duyuru', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Sistem Sağlığı ve Servis Durumları
        Text('Sistem & Altyapı Durumu', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.xs),
        BouncyCard(
          color: AppColors.surfaceHigh,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _buildServiceStatusRow('Cloud Firestore Veritabanı', 'Bağlı & Aktif', AppColors.success),
              const Divider(height: 16),
              _buildServiceStatusRow('Firebase Auth Kimlik Servisi', 'Hazır (0ms)', AppColors.success),
              const Divider(height: 16),
              _buildServiceStatusRow('GitHub REST API Kotası', '58 / 60 Kalan', AppColors.accent),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Son Sistem İşlem Günlüğü
        Text('Son Sistem Aktiviteleri', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.xs),
        BouncyCard(
          color: AppColors.surfaceHigh,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _systemLogs.take(4).map((log) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log,
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceStatusRow(String service, String status, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            service,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(status, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: statusColor)),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // 2. KULLANICILAR TAB
  // ==========================================
  Widget _buildUsersTab() {
    final filtered = _users.where((u) {
      final matchesRole = switch (_userRoleFilter) {
        'student' => u.role == UserRole.student,
        'teacher' => u.role == UserRole.teacher,
        'admin' => u.role == UserRole.admin,
        _ => true,
      };
      final q = _userSearchQuery.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          u.fullName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          (u.studentNo != null && u.studentNo!.toLowerCase().contains(q));
      return matchesRole && matchesQuery;
    }).toList();

    return Column(
      children: [
        // Arama ve Filtreleme Başlığı
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('admin_user_search_field'),
                  controller: _userSearchCtrl,
                  onChanged: (val) => setState(() => _userSearchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Kullanıcı adı, e-posta veya no ile ara...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _userSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _userSearchCtrl.clear();
                              setState(() => _userSearchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                key: const Key('admin_users_add_button'),
                onPressed: _showCreateUserDialog,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ),

        // Rol Filtre Butonları (Chips)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
          child: Row(
            children: [
              _buildRoleFilterChip('all', 'Tümü (${_users.length})'),
              const SizedBox(width: AppSpacing.xs),
              _buildRoleFilterChip('student', 'Öğrenciler (${_users.where((u) => u.role == UserRole.student).length})'),
              const SizedBox(width: AppSpacing.xs),
              _buildRoleFilterChip('teacher', 'Öğretmenler (${_users.where((u) => u.role == UserRole.teacher).length})'),
              const SizedBox(width: AppSpacing.xs),
              _buildRoleFilterChip('admin', 'Yöneticiler (${_users.where((u) => u.role == UserRole.admin).length})'),
            ],
          ),
        ),
        const Divider(height: 1),

        // Kullanıcı Listesi
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.onSurfaceMuted),
                      const SizedBox(height: 8),
                      const Text('Kullanıcı bulunamadı', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showCreateUserDialog,
                        icon: const Icon(Icons.person_add_rounded),
                        label: const Text('Yeni Kullanıcı Oluştur'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final u = filtered[index];
                    final roleAccent = switch (u.role) {
                      UserRole.admin => AppColors.accent,
                      UserRole.teacher => AppColors.secondary,
                      UserRole.student => AppColors.primary,
                    };

                    return BouncyCard(
                      key: Key('admin_user_card_${u.uid}'),
                      borderRadius: 20,
                      border: Border.all(color: roleAccent.withValues(alpha: 0.35), width: 1.2),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: roleAccent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: roleAccent.withValues(alpha: 0.4)),
                            ),
                            child: Center(
                              child: Icon(
                                switch (u.role) {
                                  UserRole.admin => Icons.admin_panel_settings_rounded,
                                  UserRole.teacher => Icons.person_rounded,
                                  UserRole.student => Icons.school_rounded,
                                },
                                color: roleAccent,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                                Text(
                                  '${u.email}${u.studentNo != null ? " • No: ${u.studentNo}" : ""}',
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.onSurfaceMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: roleAccent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: roleAccent.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              switch (u.role) {
                                UserRole.admin => 'Admin',
                                UserRole.teacher => 'Öğretmen',
                                UserRole.student => 'Öğrenci',
                              },
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: roleAccent),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            key: Key('admin_delete_user_${u.uid}'),
                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                            tooltip: 'Kullanıcıyı Sil',
                            onPressed: () {
                              _confirmDelete(
                                title: 'Kullanıcıyı Sil',
                                message: '${u.fullName} kullanıcısını sistemden silmek istediğinize emin misiniz?',
                                onConfirmed: () {
                                  setState(() {
                                    _users.removeWhere((item) => item.uid == u.uid);
                                  });
                                  _addLog('Kullanıcı silindi: ${u.fullName}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${u.fullName} silindi.'), backgroundColor: AppColors.error),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRoleFilterChip(String key, String label) {
    final isSelected = _userRoleFilter == key;
    return ChoiceChip(
      key: Key('admin_filter_chip_$key'),
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _userRoleFilter = key);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        fontSize: 11.5,
      ),
    );
  }

  // ==========================================
  // 3. SINIFLAR TAB
  // ==========================================
  Widget _buildClassesTab() {
    return Column(
      children: [
        // Sınıflar Başlık ve Yeni Sınıf Butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Aktif Sınıflar (${_classes.length})',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              FilledButton.icon(
                key: const Key('admin_classes_add_button'),
                onPressed: _showCreateClassDialog,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Yeni Sınıf', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Sınıflar Grid Listesi
        Expanded(
          child: _classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.meeting_room_outlined, size: 48, color: AppColors.onSurfaceMuted),
                      const SizedBox(height: 8),
                      const Text('Kayıtlı sınıf bulunamadı', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showCreateClassDialog,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Yeni Sınıf Ekle'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final c = _classes[index];
                    final classId = c['id']?.toString() ?? 'cls_$index';

                    return BouncyCard(
                      key: Key('admin_class_card_$classId'),
                      borderRadius: 16,
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 1.2),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                                ),
                                child: const Icon(Icons.meeting_room_rounded, color: AppColors.secondary, size: 17),
                              ),
                              IconButton(
                                key: Key('admin_delete_class_$classId'),
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Sınıfı Sil',
                                onPressed: () {
                                  _confirmDelete(
                                    title: 'Sınıfı Sil',
                                    message: '${c['name']} sınıfını silmek istediğinize emin misiniz?',
                                    onConfirmed: () {
                                      setState(() {
                                        _classes.removeAt(index);
                                      });
                                      _addLog('Sınıf silindi: ${c['name']}');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${c['name']} silindi.'), backgroundColor: AppColors.error),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            c['name'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, height: 1.2),
                          ),
                          const Spacer(),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${c['gradeLevel']}. Sınıf',
                                style: const TextStyle(fontSize: 10.5, color: AppColors.secondary, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${c['studentCount']} Öğr.',
                                style: const TextStyle(fontSize: 10.5, color: AppColors.onSurfaceMuted, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // 4. DERSLER TAB
  // ==========================================
  Widget _buildCoursesTab() {
    final filtered = _courses.where((c) {
      final q = _courseSearchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      final code = (c['code'] as String).toLowerCase();
      final name = (c['name'] as String).toLowerCase();
      final teacher = (c['teacher'] as String).toLowerCase();
      return code.contains(q) || name.contains(q) || teacher.contains(q);
    }).toList();

    return Column(
      children: [
        // Dersler Arama & Ekleme Çubuğu
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('admin_course_search_field'),
                  controller: _courseSearchCtrl,
                  onChanged: (val) => setState(() => _courseSearchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Ders kodu veya adı ile ara...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _courseSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _courseSearchCtrl.clear();
                              setState(() => _courseSearchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                key: const Key('admin_courses_add_button'),
                onPressed: _showCreateCourseDialog,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Yeni Ders', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Dersler Grid Listesi
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 48, color: AppColors.onSurfaceMuted),
                      const SizedBox(height: 8),
                      const Text('Ders bulunamadı', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showCreateCourseDialog,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Yeni Ders Ekle'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    final code = c['code'] as String;

                    return BouncyCard(
                      key: Key('admin_course_card_$code'),
                      borderRadius: 16,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    code,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHigh,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${c['credits']} Kr', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
                              ),
                              const Spacer(),
                              IconButton(
                                key: Key('admin_delete_course_$code'),
                                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                                tooltip: 'Dersi Sil',
                                onPressed: () {
                                  _confirmDelete(
                                    title: 'Dersi Sil',
                                    message: '$code - ${c['name']} dersini silmek istediğinize emin misiniz?',
                                    onConfirmed: () {
                                      setState(() {
                                        _courses.removeWhere((item) => item['code'] == code);
                                      });
                                      _addLog('Ders silindi: $code');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('$code dersi silindi.'), backgroundColor: AppColors.error),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            c['name'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, height: 1.2),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.onSurfaceMuted),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  c['teacher'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // 5. DUYURULAR TAB
  // ==========================================
  Widget _buildAnnouncementsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Yayınlanan Duyurular (${_announcements.length})',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              FilledButton.icon(
                key: const Key('admin_announcements_add_button'),
                onPressed: _showAddAnnouncementDialog,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Yeni Duyuru', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: _announcements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.campaign_outlined, size: 48, color: AppColors.onSurfaceMuted),
                      const SizedBox(height: 8),
                      const Text('Yayınlanmış duyuru bulunmuyor', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showAddAnnouncementDialog,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Yeni Duyuru Yayınla'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) {
                    final a = _announcements[index];
                    final title = a['title'] as String;

                    return BouncyCard(
                      key: Key('admin_announcement_card_$index'),
                      borderRadius: 20,
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.35), width: 1.2),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.campaign_rounded, color: AppColors.accent, size: 14),
                                    SizedBox(width: 4),
                                    Text('Duyuru', style: TextStyle(color: AppColors.accent, fontSize: 10.5, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                                ),
                              ),
                              IconButton(
                                key: Key('admin_delete_announcement_$index'),
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Duyuruyu Sil',
                                onPressed: () {
                                  _confirmDelete(
                                    title: 'Duyuruyu Sil',
                                    message: '"$title" duyurusunu silmek istediğinize emin misiniz?',
                                    onConfirmed: () {
                                      setState(() {
                                        _announcements.removeAt(index);
                                      });
                                      _addLog('Duyuru silindi: $title');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Duyuru silindi.'), backgroundColor: AppColors.error),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              a['body'] as String,
                              style: const TextStyle(fontSize: 12.5, height: 1.35),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  a['author'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppDateUtils.formatDate(a['date'] as DateTime),
                                style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
