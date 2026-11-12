// ==============================================================================
// 📌 DOSYA: lib/features/home/presentation/screens/student_shell_screen.dart
// 📌 AÇIKLAMA: Öğrenci ana kabuk (shell) ekranı.
//              5 ana sekme içerir:
//              1. Özet (Performans grafiği, yaklaşan ödevler karuseli, devamsızlık durumu)
//              2. Ödevlerim (Tümü, Açık, Teslim Edilenler, Süresi Dolanlar filtresi)
//              3. Notlar & Başarı (Vize/Final sınav notları, harf notu ve GNO ortalaması)
//              4. Haftalık Program (Günlük ders programı ve saatleri)
//              5. Profilim (GitHub kullanıcı adı bağlama ve hesap bilgileri)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/demo/demo_data.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/assignment_vertical_card.dart';
import '../../../../core/widgets/bouncy_card.dart';
import '../../../../core/widgets/sweet_progress_bar.dart';
import '../../../../core/widgets/zigzag_chart.dart';
import '../../../assignments/domain/entities/assignment.dart';
import '../../../assignments/domain/entities/late_policy.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../submissions/presentation/screens/submit_assignment_screen.dart';
import '../../../users/domain/entities/app_user.dart';

/// [StudentShellScreen], öğrenci rolündeki kullanıcıların tüm OBS ve ödev akışını barındırır.
class StudentShellScreen extends ConsumerStatefulWidget {
  const StudentShellScreen({super.key});

  @override
  ConsumerState<StudentShellScreen> createState() => _StudentShellScreenState();
}

class _StudentShellScreenState extends ConsumerState<StudentShellScreen> {
  int _currentIndex = 0;
  String _assignmentFilter = 'all';
  String _selectedScheduleDay = 'Pazartesi';

  final _githubUsernameController = TextEditingController();
  bool _isEditingGithub = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProfileProvider).value;
    if (user?.githubUsername != null) {
      _githubUsernameController.text = user!.githubUsername!;
    }
  }

  @override
  void dispose() {
    _githubUsernameController.dispose();
    super.dispose();
  }

  void _openSubmitScreen(Assignment assignment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubmitAssignmentScreen(assignment: assignment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('student_back_button'),
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
            0 => 'EduTrack — Öğrenci',
            1 => 'Ödevlerim',
            2 => 'Notlar & Başarı',
            3 => 'Haftalık Program',
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
              _buildAssignmentsTab(),
              _buildGradesTab(),
              _buildScheduleTab(),
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
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Ödevler',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_graph_rounded),
            selectedIcon: Icon(Icons.auto_graph_rounded),
            label: 'Notlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Program',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // 1. ANA SAYFA (NORDIC PINE & BOUNCY BENTO)
  Widget _buildHomeTab(AppUser user) {
    final assignments = DemoData.sampleAssignments;
    final activeCount = assignments.where((a) => a.getSubmissionState() != SubmissionState.closed).length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Hoş Geldiniz Maskot Kartı
        BouncyCard(
          color: AppColors.surfaceContainer,
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'Ö',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'İyi çalışmalar,',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Öğrenci No: ${user.studentNo ?? "2024101"} • 3. Sınıf',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Şık Zikzaklı Performans & Commit Aktivite Grafiği
        const ZigzagChartWidget(
          dataPoints: [2.85, 3.40, 3.10, 3.65, 3.42, 3.82, 3.52, 3.90],
          lineColor: AppColors.primary,
          glowColor: AppColors.accent,
          height: 100,
          title: 'Akademik Başarı & Commit Grafiği',
          subtitle: 'Haftalık ritim ve GitHub commit grafiği',
        ),

        const SizedBox(height: AppSpacing.md),

        // İstatistik Sayaçları (Kompakt Bento Grid - Okunaklı ve Net)
        Row(
          children: [
            Expanded(
              child: BouncyCard(
                color: AppColors.surfaceHigh,
                borderRadius: 16,
                margin: const EdgeInsets.only(right: 5, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.assignment_outlined, size: 20, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text(
                      '$activeCount',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Aktif Ödev',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BouncyCard(
                color: AppColors.surfaceHigh,
                borderRadius: 16,
                margin: const EdgeInsets.only(left: 3, right: 3, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.grade_rounded, size: 20, color: AppColors.accent),
                    SizedBox(height: 4),
                    Text(
                      '3.52',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Dönem GANO',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BouncyCard(
                color: AppColors.surfaceHigh,
                borderRadius: 16,
                margin: const EdgeInsets.only(left: 5, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.task_alt_rounded, size: 20, color: AppColors.secondary),
                    SizedBox(height: 4),
                    Text(
                      '1',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Teslim Edilen',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Yaklaşan Ödevler (Büyük & Okunaklı Yazılı Dikey Kart Destesi)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.assignment_late_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Teslim Bekleyen Ödevler',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Text('Tümü', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Okunaklı Dikey Poster Kartları Destesi (168px yükseklik, 160px genişlik)
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: assignments.length,
            separatorBuilder: (_, _) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final a = assignments[index];
              final sub = DemoData.sampleStudentSubmissions[a.id];
              return AssignmentVerticalCard(
                width: 160,
                assignment: a,
                submission: sub,
                onTap: () => _openSubmitScreen(a),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Son Duyurular
        Text(
          'Okul Duyuruları',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...DemoData.sampleAnnouncements.map(
          (ann) => BouncyCard(
            borderRadius: 24,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.campaign_rounded, color: AppColors.primary, size: 16),
                          SizedBox(width: 4),
                          Text('Duyuru', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        ann['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    ann['body'] as String,
                    style: const TextStyle(height: 1.35),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          ann['author'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        AppDateUtils.formatDate(ann['date'] as DateTime),
                        style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 2. ÖDEVLERİM SEKMESİ
  Widget _buildAssignmentsTab() {
    final allAssignments = DemoData.sampleAssignments;
    final filtered = allAssignments.where((a) {
      final state = a.getSubmissionState();
      final isSubmitted = DemoData.sampleStudentSubmissions.containsKey(a.id);

      return switch (_assignmentFilter) {
        'open' => state == SubmissionState.open && !isSubmitted,
        'late' => state == SubmissionState.late && !isSubmitted,
        'submitted' => isSubmitted,
        'closed' => state == SubmissionState.closed,
        _ => true,
      };
    }).toList();

    return Column(
      children: [
        // Filtre Butonları
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: [
              _buildFilterChip('all', 'Tümü (${allAssignments.length})'),
              const SizedBox(width: AppSpacing.xs),
              _buildFilterChip('open', 'Açık'),
              const SizedBox(width: AppSpacing.xs),
              _buildFilterChip('late', 'Geç Teslim'),
              const SizedBox(width: AppSpacing.xs),
              _buildFilterChip('submitted', 'Teslim Edildi'),
              const SizedBox(width: AppSpacing.xs),
              _buildFilterChip('closed', 'Kapalı'),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Bu filtreye uygun ödev bulunamadı.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 0.94,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final a = filtered[index];
                    final sub = DemoData.sampleStudentSubmissions[a.id];
                    return AssignmentVerticalCard(
                      assignment: a,
                      submission: sub,
                      onTap: () => _openSubmitScreen(a),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _assignmentFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _assignmentFilter = key);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.22),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
      ),
    );
  }

  // 3. NOTLARIM SEKMESİ
  Widget _buildGradesTab() {
    final grades = DemoData.sampleGrades;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Şık Zikzaklı Not & Başarı Grafiği
        const ZigzagChartWidget(
          dataPoints: [62, 85, 74, 95, 84, 96, 91],
          lineColor: AppColors.secondary,
          glowColor: AppColors.primary,
          height: 100,
          title: 'Sınav & Başarı Eğrisi',
          subtitle: 'Dönem içi not dalgalanmaları ve zirve ritmi',
        ),
        const SizedBox(height: AppSpacing.md),

        // GANO Kartı
        BouncyCard(
          color: AppColors.surfaceContainer,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dönem Not Ortalaması (GANO)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '3.52 / 4.00',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      'YÜKSEK ONUR',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const SweetProgressBar(
                progress: 0.88,
                label: 'Akademik Başarı Seviyesi',
                subtitle: 'Bölüm genelinde ilk %10 dilimdesiniz',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Text(
          'Ders Başarı Tablosu (Dikey Kartlar)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),

        // 2 Sütunlu Kompakt Dikey Ders Notu Kartları (Büyük & Okunaklı)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.94,
          ),
          itemCount: grades.length,
          itemBuilder: (context, index) {
            final g = grades[index];
            final letter = g['letter'] as String;
            final gradeAccent = switch (letter) {
              'AA' || 'BA' => AppColors.primary,
              'BB' || 'CB' => AppColors.accent,
              'CC' || 'DC' => AppColors.secondary,
              _ => AppColors.error,
            };

            return BouncyCard(
              borderRadius: 16,
              border: Border.all(color: gradeAccent.withValues(alpha: 0.4), width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          g['code'] as String,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: gradeAccent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: gradeAccent.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          letter,
                          style: TextStyle(
                            color: gradeAccent,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    g['name'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.15),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildMiniGrade('Vize', '${g['midterm']}')),
                        Expanded(child: _buildMiniGrade('Final', '${g['final']}')),
                        Expanded(child: _buildMiniGrade('Ort.', '${g['average']}', isHighlighted: true, highlightColor: gradeAccent)),
                      ],
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

  Widget _buildMiniGrade(String label, String value, {bool isHighlighted = false, Color? highlightColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceMuted, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.w800,
            color: isHighlighted ? (highlightColor ?? AppColors.primary) : AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  // 4. HAFTALIK DERS PROGRAMI
  Widget _buildScheduleTab() {
    final days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma'];
    final scheduleForDay = DemoData.sampleSchedule.where((s) => s['day'] == _selectedScheduleDay).toList();

    return Column(
      children: [
        // Gün Seçici Tablar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: days
                .map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: _selectedScheduleDay == d,
                      onSelected: (val) {
                        if (val) setState(() => _selectedScheduleDay = d);
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.22),
                      labelStyle: TextStyle(
                        color: _selectedScheduleDay == d ? AppColors.primary : AppColors.onSurfaceVariant,
                        fontWeight: _selectedScheduleDay == d ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: scheduleForDay.isEmpty
              ? Center(child: Text('$_selectedScheduleDay günü ders bulunmuyor.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: scheduleForDay.length,
                  itemBuilder: (context, index) {
                    final item = scheduleForDay[index];
                    const scheduleAccents = [
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.accent,
                      AppColors.violet,
                    ];
                    final accent = scheduleAccents[index % scheduleAccents.length];

                    return BouncyCard(
                      borderRadius: 16,
                      border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: accent.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.schedule_rounded, size: 11, color: accent),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          item['time'] as String,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: accent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHigh,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item['room'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['name'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.15),
                          ),
                          const Spacer(),
                          Text(
                            item['teacher'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.onSurfaceMuted,
                              fontWeight: FontWeight.w700,
                            ),
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
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'Ö',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const Divider(height: AppSpacing.xl),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.badge_rounded, color: AppColors.primary),
                title: const Text('Öğrenci Numarası'),
                subtitle: Text(user.studentNo ?? '2024101'),
              ),
              const Divider(),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.school_rounded, color: AppColors.primary),
                title: Text('Kayıtlı Sınıf'),
                subtitle: Text('Bilgisayar Mühendisliği 3. Sınıf'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.code_rounded, color: AppColors.primary),
                title: const Text('GitHub Kullanıcı Adı'),
                subtitle: _isEditingGithub
                    ? TextField(
                        controller: _githubUsernameController,
                        decoration: const InputDecoration(
                          hintText: 'örn: octocat',
                          isDense: true,
                        ),
                      )
                    : Text(user.githubUsername ?? 'Belirtilmedi'),
                trailing: IconButton(
                  icon: Icon(_isEditingGithub ? Icons.check_rounded : Icons.edit_rounded),
                  onPressed: () {
                    if (_isEditingGithub) {
                      final updatedUser = user.copyWith(
                        githubUsername: _githubUsernameController.text.trim(),
                      );
                      ref.read(authControllerProvider.notifier).updateProfile(updatedUser);
                    }
                    setState(() => _isEditingGithub = !_isEditingGithub);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
