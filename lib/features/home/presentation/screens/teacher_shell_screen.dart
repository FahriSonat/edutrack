// ==============================================================================
// 📌 DOSYA: lib/features/home/presentation/screens/teacher_shell_screen.dart
// 📌 AÇIKLAMA: Öğretmen ana kabuk (shell) ekranı.
//              5 ana sekme içerir:
//              1. Özet (Aktif dersler, bekleyen teslim incelemeleri, hızlı ödev oluşturma)
//              2. Derslerim (Verilen ders listesi ve kayıtlı öğrenci sayıları)
//              3. Ödev & Teslimler (Ödev açma, öğrenci teslimlerini inceleme ve notlandırma)
//              4. Yoklama Sistemi (Öğrenci bazlı devamsızlık durumu girme)
//              5. Profilim (Varsayılan geç teslim politikası ve öğretmen ayarları)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/demo/demo_data.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/bouncy_card.dart';
import '../../../../core/widgets/zigzag_chart.dart';
import '../../../assignments/domain/entities/assignment.dart';
import '../../../assignments/domain/entities/late_policy.dart';
import '../../../assignments/presentation/screens/create_assignment_screen.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../submissions/presentation/screens/submission_review_screen.dart';
import '../../../users/domain/entities/app_user.dart';

/// [TeacherShellScreen], öğretmen rolündeki kullanıcıların ders ve ödev yönetimini sağlar.
class TeacherShellScreen extends ConsumerStatefulWidget {
  const TeacherShellScreen({super.key});

  @override
  ConsumerState<TeacherShellScreen> createState() => _TeacherShellScreenState();
}

class _TeacherShellScreenState extends ConsumerState<TeacherShellScreen> {
  int _currentIndex = 0;
  final Map<String, String> _attendanceMap = {
    '2024101': 'present',
    '2024102': 'present',
    '2024103': 'absent',
  };

  Future<void> _openCreateAssignment() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreateAssignmentScreen(),
      ),
    );
    if (created == true || mounted) {
      setState(() {});
    }
  }

  void _openReviewScreen(Assignment assignment) {
    final submission = DemoData.teacherSampleSubmissions.first;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubmissionReviewScreen(
          assignment: assignment,
          submission: submission,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('teacher_back_button'),
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
            0 => 'EduTrack — Öğretmen',
            1 => 'Derslerim',
            2 => 'Ödev & Teslimler',
            3 => 'Yoklama Sistemi',
            _ => 'Profilim',
          },
        ),
        actions: [
          IconButton(
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
              _buildCoursesTab(),
              _buildAssignmentsTab(),
              _buildAttendanceTab(),
              _buildProfileTab(user),
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
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Derslerim',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Ödevler',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined),
            selectedIcon: Icon(Icons.how_to_reg_rounded),
            label: 'Yoklama',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton.extended(
              onPressed: _openCreateAssignment,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Yeni Ödev', style: TextStyle(fontWeight: FontWeight.w700)),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            )
          : null,
    );
  }

  // 1. ÖĞRETMEN ANA SAYFA
  Widget _buildHomeTab(AppUser user) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        BouncyCard(
          color: AppColors.surfaceContainer,
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, Color(0xFFFBBF24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'Ö',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.onSecondary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Öğretim Üyesi Paneli',
                      style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Bilgisayar Mühendisliği Bölümü',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Şık Zikzaklı Teslim & Aktivite Grafiği
        const ZigzagChartWidget(
          dataPoints: [8, 15, 11, 26, 22, 34, 29, 38],
          lineColor: AppColors.accent,
          glowColor: AppColors.primary,
          height: 100,
          title: 'Öğrenci Teslim & Aktivite Eğrisi',
          subtitle: 'Haftalık teslim ve commit hareketliliği',
        ),

        const SizedBox(height: AppSpacing.xs),

        // Sayaçlar (Bento Grid)
        Row(
          children: [
            Expanded(
              child: BouncyCard(
                color: AppColors.surfaceHigh,
                margin: const EdgeInsets.only(right: 6, bottom: 12),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.assignment_outlined, size: 22, color: AppColors.primary),
                    SizedBox(height: 8),
                    Text('4', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    SizedBox(height: 2),
                    Text('Aktif Ödev', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BouncyCard(
                color: AppColors.surfaceHigh,
                margin: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.hourglass_top_rounded, size: 22, color: AppColors.secondary),
                    SizedBox(height: 8),
                    Text('3', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                    SizedBox(height: 2),
                    Text('Bekleyen Teslim', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BouncyCard(
                color: AppColors.surfaceHigh,
                margin: const EdgeInsets.only(left: 6, bottom: 12),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.school_outlined, size: 22, color: AppColors.accent),
                    SizedBox(height: 8),
                    Text('42', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.accent)),
                    SizedBox(height: 2),
                    Text('Öğrenci', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // Hızlı İşlemler
        Text('Hızlı İşlemler', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _openCreateAssignment,
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Yeni Ödev Ver'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _currentIndex = 3),
                icon: const Icon(Icons.how_to_reg_rounded),
                label: const Text('Yoklama Al'),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // Bekleyen Teslimler Önizlemesi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Son Gelen Öğrenci Teslimleri', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 2),
              child: const Text('Tümünü İncele', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        ...DemoData.teacherSampleSubmissions.map(
          (sub) {
            final accent = sub.isGraded
                ? AppColors.primary
                : (sub.isLate ? AppColors.warning : AppColors.accent);
            return BouncyCard(
              borderRadius: 24,
              border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.2),
              padding: const EdgeInsets.all(12),
              onTap: () => _openReviewScreen(DemoData.sampleAssignments.first),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: accent.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Icon(
                        sub.isGraded ? Icons.grade_rounded : Icons.school_rounded,
                        color: accent,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub.studentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          '${sub.repoOwner ?? "repo"}/${sub.repoName ?? "proje"} • ${sub.commitCount ?? 0} commit'
                          '${sub.attachedFiles.isNotEmpty ? " • Dosya: ${sub.attachedFiles.length}" : ""}',
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: accent.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      sub.isGraded ? '${sub.score} Puan' : (sub.isLate ? 'Geç Teslim' : 'Teslim Edildi'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 2. DERSLERİM SEKMESİ (2-Sütunlu Dikey Kartlar)
  Widget _buildCoursesTab() {
    final courses = [
      {'code': 'CENG301', 'name': 'Mobil Uygulama Geliştirme', 'class': '3. Sınıf', 'students': 42, 'credits': 4},
      {'code': 'CENG302', 'name': 'Yazılım Mimarisi', 'class': '3. Sınıf', 'students': 45, 'credits': 3},
      {'code': 'CENG401', 'name': 'Bitirme Tezi Projesi', 'class': '4. Sınıf', 'students': 18, 'credits': 5},
    ];

    const courseAccents = [AppColors.primary, AppColors.secondary, AppColors.accent];

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.94,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final c = courses[index];
        final accent = courseAccents[index % courseAccents.length];

        return BouncyCard(
          borderRadius: 18,
          border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accent.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        c['code'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 10.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${c['credits']} Kr', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                c['name'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, height: 1.2),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_alt_outlined, size: 12, color: accent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${c['students']} Öğr. • ${c['class']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. ÖDEV YÖNETİMİ SEKMESİ (2-Sütunlu Kompakt Dikey Kartlar)
  Widget _buildAssignmentsTab() {
    final assignments = DemoData.sampleAssignments;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.xs),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.92,
      ),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final a = assignments[index];
        final state = a.getSubmissionState();
        final accentColor = switch (state) {
          SubmissionState.open => AppColors.primary,
          SubmissionState.late => AppColors.warning,
          SubmissionState.closed => AppColors.error,
        };

        return BouncyCard(
          borderRadius: 16,
          border: Border.all(color: accentColor.withValues(alpha: 0.45), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        a.courseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w800, fontSize: 10.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      switch (state) {
                        SubmissionState.open => 'Açık',
                        SubmissionState.late => 'Geç',
                        SubmissionState.closed => 'Kapalı',
                      },
                      style: TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: 10.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                a.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.15),
              ),
              const Spacer(),
              // Mini İlerleme Kapsülü
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '18/24 Teslim',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceMuted),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '%75',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: const LinearProgressIndicator(
                        value: 0.75,
                        minHeight: 4,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => _openReviewScreen(a),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('İncele (3)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 4. YOKLAMA SİSTEMİ
  Widget _buildAttendanceTab() {
    final students = [
      {'no': '2024101', 'name': 'Ahmet Yılmaz'},
      {'no': '2024102', 'name': 'Zeynep Kaya'},
      {'no': '2024103', 'name': 'Burak Demir'},
      {'no': '2024104', 'name': 'Merve Çelik'},
      {'no': '2024105', 'name': 'Caner Öztürk'},
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        BouncyCard(
          borderRadius: 24,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ders:', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                    const SizedBox(height: 2),
                    const Text(
                      'Mobil Uygulama (CENG301)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
                child: Text(
                  AppDateUtils.formatDate(DateTime.now()),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Öğrenci Yoklama Listesi', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.sm),
        ...students.map(
          (s) {
            final isPresent = (_attendanceMap[s['no']] ?? 'present') == 'present';
            final statusColor = isPresent ? AppColors.primary : AppColors.error;

            return BouncyCard(
              borderRadius: 22,
              border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1.2),
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        isPresent ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('No: ${s['no']}', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                      ],
                    ),
                  ),
                  SegmentedButton<String>(
                    style: SegmentedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    segments: const [
                      ButtonSegment(value: 'present', label: Text('Var')),
                      ButtonSegment(value: 'absent', label: Text('Yok')),
                    ],
                    selected: {isPresent ? 'present' : 'absent'},
                    onSelectionChanged: (set) {
                      setState(() => _attendanceMap[s['no']!] = set.first);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Yoklama kaydedildi!'), backgroundColor: AppColors.success),
            );
          },
          icon: const Icon(Icons.check_circle_rounded),
          label: const Text('Yoklamayı Tamamla ve Kaydet'),
        ),
      ],
    );
  }

  // 5. PROFİL SEKMESİ
  Widget _buildProfileTab(AppUser user) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        BouncyCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'Ö',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(user.fullName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              Text(user.email, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
              const Divider(height: AppSpacing.xl),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.work_outline_rounded, color: AppColors.primary),
                title: Text('Akademik Unvan'),
                subtitle: Text('Öğretim Görevlisi / Dr.'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.policy_outlined, color: AppColors.primary),
                title: const Text('Varsayılan Geç Teslim Politikası'),
                subtitle: Text(
                  user.defaultLatePolicy == 'allowLate'
                      ? 'Geç Teslime İzin Ver (Ödev oluştururken otomatik seçilir)'
                      : 'Geç Teslime Kapalı',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
