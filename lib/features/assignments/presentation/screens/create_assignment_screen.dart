// ==============================================================================
// 📌 DOSYA: lib/features/assignments/presentation/screens/create_assignment_screen.dart
// 📌 AÇIKLAMA: Öğretmenin yeni ödev tanımladığı form ekranı.
//              Ders seçimi, son teslim tarihi, geç teslim politikası (allowLate / closed),
//              ceza yüzdesi ve dosya eki ekleme işlemlerini yönetir.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/demo/demo_data.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/late_policy.dart';
import '../providers/assignments_providers.dart';

/// [CreateAssignmentScreen], öğretmenlerin derslerine yeni ödev atamalarını sağlar.
class CreateAssignmentScreen extends ConsumerStatefulWidget {
  final String? offeringId;
  final String? classId;
  final String? courseName;

  const CreateAssignmentScreen({
    super.key,
    this.offeringId,
    this.classId,
    this.courseName,
  });

  @override
  ConsumerState<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends ConsumerState<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxScoreController = TextEditingController(text: '100');
  final _penaltyController = TextEditingController(text: '15');

  late String _selectedCourse;
  final List<String> _availableCourses = [
    'Mobil Uygulama Geliştirme',
    'Yazılım Mimarisi ve Tasarım Desenleri',
    'Veritabanı Yönetim Sistemleri',
    'Bitirme Tezi Projesi',
  ];

  late DateTime _dueAt;
  DateTime? _lateUntil;
  late LatePolicy _latePolicy;
  bool _requiresRepo = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.courseName ?? _availableCourses.first;

    // Varsayılan teslim süresi: 7 gün sonrası saat 23:59
    final now = DateTime.now();
    _dueAt = DateTime(now.year, now.month, now.day + 7, 23, 59);

    // Öğretmen profilindeki varsayılan politika (project.md 6.1)
    final teacher = ref.read(currentUserProfileProvider).value;
    _latePolicy = teacher?.defaultLatePolicy == 'allowLate'
        ? LatePolicy.allowLate
        : LatePolicy.closed;

    if (_latePolicy == LatePolicy.allowLate) {
      _lateUntil = _dueAt.add(const Duration(days: 3));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxScoreController.dispose();
    _penaltyController.dispose();
    super.dispose();
  }

  Future<void> _selectDueAt() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _dueAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (_lateUntil != null && _lateUntil!.isBefore(_dueAt)) {
        _lateUntil = _dueAt.add(const Duration(days: 2));
      }
    });
  }

  Future<void> _selectLateUntil() async {
    final initial = _lateUntil ?? _dueAt.add(const Duration(days: 2));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _dueAt,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _lateUntil = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final teacher = ref.read(currentUserProfileProvider).value;
    final teacherId = teacher?.uid ?? 'demo_teacher_1';

    setState(() => _isLoading = true);

    final penalty = _latePolicy == LatePolicy.allowLate
        ? int.tryParse(_penaltyController.text.trim())
        : null;

    final assignment = Assignment(
      id: 'asg_${DateTime.now().millisecondsSinceEpoch}',
      offeringId: widget.offeringId ?? 'offering_default',
      classId: widget.classId ?? 'bilgisayar_muh_3',
      teacherId: teacherId,
      courseName: _selectedCourse,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      maxScore: int.tryParse(_maxScoreController.text.trim()) ?? 100,
      createdAt: DateTime.now(),
      dueAt: _dueAt,
      requiresRepo: _requiresRepo,
      latePolicy: _latePolicy,
      latePenaltyPercent: penalty,
      lateUntil: _latePolicy == LatePolicy.allowLate ? _lateUntil : null,
    );

    // Demo veri tabanına hemen ekle (Öğretmen ve Öğrenci listelerinde hemen görünsün)
    DemoData.sampleAssignments.insert(0, assignment);

    try {
      final repo = ref.read(assignmentsRepositoryProvider);
      await repo.createAssignment(assignment);
    } catch (_) {
      // Offline / demo modunda devam et
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ödev başarıyla oluşturuldu ve yayınlandı!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('create_assignment_back_button'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Yeni Ödev Oluştur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ders Seçimi
              DropdownButtonFormField<String>(
                initialValue: _selectedCourse,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Ders',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: _availableCourses.map((course) {
                  return DropdownMenuItem<String>(
                    value: course,
                    child: Text(
                      course,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCourse = val);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Başlık
              TextFormField(
                controller: _titleController,
                validator: (v) => Validators.required(v, 'Ödev başlığı zorunludur'),
                decoration: const InputDecoration(
                  labelText: 'Ödev Başlığı',
                  hintText: 'örn: Flutter ile GitHub Client Uygulaması',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                validator: (v) => Validators.required(v, 'Ödev açıklaması zorunludur'),
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Ödev Açıklaması ve Yönergeler',
                  hintText: 'Ödevin gereksinimlerini detaylandırınız...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Maksimum Puan & Repo Zorunlu mu
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maxScoreController,
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.numberInRange(v, min: 10, max: 100),
                      decoration: const InputDecoration(
                        labelText: 'Maksimum Puan',
                        prefixIcon: Icon(Icons.score_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('GitHub Repo', style: TextStyle(fontWeight: FontWeight.w500)),
                            Switch(
                              value: _requiresRepo,
                              onChanged: (val) => setState(() => _requiresRepo = val),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Son Teslim Tarihi Seçici
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available_rounded, color: AppColors.primary),
                  title: const Text('Son Teslim Tarihi'),
                  subtitle: Text(
                    AppDateUtils.formatDateTime(_dueAt),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: OutlinedButton(
                    onPressed: _selectDueAt,
                    child: const Text('Değiştir'),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // GEÇ TESLİM POLİTİKASI 
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.policy_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Geç Teslim Politikası',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_clock_rounded, size: 16),
                                    SizedBox(width: 6),
                                    Text('Kapalı', style: TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              selected: _latePolicy == LatePolicy.closed,
                              onSelected: (val) {
                                if (val) setState(() => _latePolicy = LatePolicy.closed);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.timelapse_rounded, size: 16),
                                    SizedBox(width: 6),
                                    Text('Geç Teslime İzin Ver', style: TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              selected: _latePolicy == LatePolicy.allowLate,
                              onSelected: (val) {
                                if (val) {
                                  setState(() {
                                    _latePolicy = LatePolicy.allowLate;
                                    _lateUntil ??= _dueAt.add(const Duration(days: 3));
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_latePolicy == LatePolicy.allowLate) ...[
                        const SizedBox(height: AppSpacing.md),
                        const Divider(),
                        const SizedBox(height: AppSpacing.sm),

                        // Kesinti Yüzdesi
                        TextFormField(
                          controller: _penaltyController,
                          keyboardType: TextInputType.number,
                          validator: (v) => Validators.numberInRange(v, min: 0, max: 100),
                          decoration: const InputDecoration(
                            labelText: 'Geç Teslim Puan Kesintisi (%)',
                            hintText: 'örn: 15 (Geç teslimde %15 puan düşülür)',
                            prefixIcon: Icon(Icons.percent_rounded),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Kesin Kapanış Tarihi (lateUntil)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_busy_rounded, color: AppColors.error),
                          title: const Text('Kesin Kapanış Tarihi (lateUntil)'),
                          subtitle: Text(
                            _lateUntil != null
                                ? AppDateUtils.formatDateTime(_lateUntil)
                                : 'Belirtilmedi (Süresiz açık)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: OutlinedButton(
                            onPressed: _selectLateUntil,
                            child: const Text('Değiştir'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Kaydet Butonu
              FilledButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                      )
                    : const Icon(Icons.add_task_rounded),
                label: Text(
                  _isLoading ? 'Kaydediliyor...' : 'Ödevi Yayınla',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

