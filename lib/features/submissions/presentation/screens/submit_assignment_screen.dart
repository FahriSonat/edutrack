// ==============================================================================
// 📌 DOSYA: lib/features/submissions/presentation/screens/submit_assignment_screen.dart
// 📌 AÇIKLAMA: Öğrencinin GitHub repo linki ve ek dosya ile ödev teslim ettiği ekran.
//              GitHub REST API ile repo analiz edilir, commit SHA'ları çıkarılır,
//              geç teslim durumu hesaplanır ve Firestore'a sunucu zamanıyla kaydedilir.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/github_url_parser.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/commit_tile.dart';
import '../../../../core/widgets/deadline_badge.dart';
import '../../../../core/widgets/file_attachment_picker.dart';
import '../../../../core/widgets/repo_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../assignments/domain/entities/assignment.dart';
import '../../../assignments/domain/entities/late_policy.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../github/domain/entities/repo_analysis.dart';
import '../../../github/presentation/providers/github_providers.dart';
import '../../domain/entities/submission.dart';
import '../../domain/entities/submission_file.dart';
import '../providers/submissions_providers.dart';

/// [SubmitAssignmentScreen], öğrenci tarafında GitHub repo teslimini ve analizini yönetir.
class SubmitAssignmentScreen extends ConsumerStatefulWidget {
  final Assignment assignment;

  const SubmitAssignmentScreen({
    super.key,
    required this.assignment,
  });

  @override
  ConsumerState<SubmitAssignmentScreen> createState() => _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState extends ConsumerState<SubmitAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repoUrlController = TextEditingController();
  final _branchController = TextEditingController();
  final _noteController = TextEditingController();

  List<SubmissionFile> _attachedFiles = [];
  bool _isCheckingRepo = false;
  bool _isSubmitting = false;
  String? _checkError;
  RepoAnalysis? _analysis;
  List<GithubCommit> _commits = [];

  final List<String> _quickNotes = [
    'Rapor ve proje dokümanı eklenmiştir.',
    'Ekran görüntüleri ve PDF dosyaları eklendi.',
    'Commit geçmişinde tüm aşamalar detaylandırılmıştır.',
  ];

  @override
  void dispose() {
    _repoUrlController.dispose();
    _branchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _checkRepo() async {
    final parsed = GithubUrlParser.parse(_repoUrlController.text);
    if (parsed == null) {
      setState(() {
        _checkError = 'Geçerli bir GitHub repo linki giriniz (örn: https://github.com/kullanici/repo)';
        _analysis = null;
      });
      return;
    }

    setState(() {
      _isCheckingRepo = true;
      _checkError = null;
    });

    final githubRepo = ref.read(githubRepositoryProvider);
    final result = await githubRepo.analyzeRepo(
      owner: parsed.owner,
      repo: parsed.repo,
      branch: _branchController.text.trim().isNotEmpty ? _branchController.text.trim() : null,
      dueAt: widget.assignment.dueAt,
    );

    if (!mounted) return;

    await result.when(
      success: (analysis) async {
        final commitsResult = await githubRepo.getCommits(
          owner: analysis.owner,
          repo: analysis.repo,
          branch: analysis.branch,
          dueAt: widget.assignment.dueAt,
        );

        if (!mounted) return;
        setState(() {
          _analysis = analysis;
          _commits = commitsResult.dataOrNull ?? [];
          _isCheckingRepo = false;
        });
      },
      failure: (failure) {
        setState(() {
          _checkError = failure.message;
          _analysis = null;
          _commits = [];
          _isCheckingRepo = false;
        });
      },
    );
  }

  Future<void> _confirmAndSubmit(String studentUid, String studentName) async {
    final state = widget.assignment.getSubmissionState();
    if (state == SubmissionState.closed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu ödev teslime kapalıdır. Teslim yapılamaz.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Ödevi Teslim Et'),
        content: Text(
          state == SubmissionState.late
              ? 'Dikkat: Teslim süresi dolmuştur! Bu teslim geç teslim olarak işaretlenecek'
                  '${widget.assignment.latePenaltyPercent != null ? " ve nota %${widget.assignment.latePenaltyPercent} ceza uygulanacaktır" : ""}. Onaylıyor musunuz?'
              : 'Ödevinizi teslim etmek istediğinize emin misiniz? ${_attachedFiles.isNotEmpty ? "(${_attachedFiles.length} dosya eklendi)" : ""}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Evet, Teslim Et'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    final submission = Submission(
      studentUid: studentUid,
      studentName: studentName,
      submittedAt: DateTime.now(),
      isLate: state == SubmissionState.late,
      repoUrl: _repoUrlController.text.trim(),
      repoOwner: _analysis?.owner,
      repoName: _analysis?.repo,
      branch: _analysis?.branch,
      latestCommitSha: _analysis?.latestCommitSha,
      commitCount: _analysis?.commitCount,
      firstCommitAt: _analysis?.firstCommitAt,
      lastCommitAt: _analysis?.lastCommitAt,
      commitsAfterDeadline: _analysis?.commitsAfterDeadline ?? 0,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      attachedFiles: _attachedFiles,
    );

    final subRepo = ref.read(submissionsRepositoryProvider);
    final res = await subRepo.submit(
      assignmentId: widget.assignment.id,
      submission: submission,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    res.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödeviniz başarıyla teslim edildi!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      },
      failure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = widget.assignment.getSubmissionState();
    final user = ref.watch(currentUserProfileProvider).value;
    final isClosed = submissionState == SubmissionState.closed;
    final isLate = submissionState == SubmissionState.late;

    final isOwnerMismatch = _analysis != null &&
        user?.githubUsername != null &&
        user!.githubUsername!.isNotEmpty &&
        _analysis!.owner.toLowerCase() != user.githubUsername!.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('submit_assignment_back_button'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Ödev Teslimi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ödev Başlık & Bilgi Kartı (Soft Stille)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.assignment.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          StatusChip(
                            status: switch (submissionState) {
                              SubmissionState.open => StatusType.open,
                              SubmissionState.late => StatusType.lateSubmission,
                              SubmissionState.closed => StatusType.closed,
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.assignment.courseName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.assignment.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                      const Divider(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Son Teslim Tarihi',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.onSurfaceMuted,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppDateUtils.formatDateTime(widget.assignment.dueAt),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          DeadlineBadge(deadline: widget.assignment.dueAt),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Durum Banner'ları
              if (isClosed)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_rounded, color: AppColors.error),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Bu ödev teslime kapalıdır. Teslim süresi dolmuş veya son kapanış tarihi aşılmıştır.',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isLate)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warningSoft.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Süre doldu! Bu ödevde geç teslim kabul edilmektedir'
                          '${widget.assignment.latePenaltyPercent != null ? " (Kesinti: %${widget.assignment.latePenaltyPercent})" : ""}.',
                          style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.lg),

              if (!isClosed) ...[
                // Repo Bilgisi Girişi
                Text(
                  'GitHub Repository Linki',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _repoUrlController,
                  validator: Validators.githubRepoUrl,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(
                    labelText: 'GitHub Repo URL',
                    hintText: 'https://github.com/kullanici/proje-adi',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _branchController,
                  enabled: !_isSubmitting,
                  decoration: const InputDecoration(
                    labelText: 'Branch (Opsiyonel, varsayılan: main)',
                    hintText: 'main',
                    prefixIcon: Icon(Icons.fork_right_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Repoyu Kontrol Et Butonu
                OutlinedButton.icon(
                  onPressed: _isCheckingRepo || _isSubmitting ? null : _checkRepo,
                  icon: _isCheckingRepo
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(_isCheckingRepo ? 'GitHub İnceleniyor...' : 'Repoyu ve Commitleri Kontrol Et'),
                ),

                if (_checkError != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _checkError!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],

                if (_analysis != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  RepoCard(
                    owner: _analysis!.owner,
                    repo: _analysis!.repo,
                    branch: _analysis!.branch,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (isOwnerMismatch)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Uyarı: Repo sahibi (${_analysis!.owner}), profildeki kullanıcı adınızla (${user.githubUsername}) eşleşmiyor.',
                              style: const TextStyle(color: AppColors.warning, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Commit Özeti Kartı
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Commit Analizi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Toplam Commit: ${_analysis!.commitCount}'),
                              if (_analysis!.commitsAfterDeadline > 0)
                                Text(
                                  'Süre Sonrası: ${_analysis!.commitsAfterDeadline}',
                                  style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold),
                                )
                              else
                                const Text(
                                  'Tüm Commitler Zamanında',
                                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            'Son Commit: ${AppDateUtils.formatDateTime(_analysis!.lastCommitAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Son Commitler
                  if (_commits.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Son Commitler',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ..._commits.take(4).map(
                          (c) => CommitTile(
                            sha: c.sha,
                            message: c.message,
                            date: c.date,
                            isAfterDeadline: c.isAfterDeadline,
                          ),
                        ),
                  ],
                ],

                const SizedBox(height: AppSpacing.xl),

                // YENİ ÖZELLİK 1: DOSYA EKLEME (.pdf, .doc, .docx, .jpg, .png)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: FileAttachmentPicker(
                      files: _attachedFiles,
                      onFilesChanged: (files) => setState(() => _attachedFiles = files),
                      isEnabled: !_isSubmitting,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // YENİ ÖZELLİK 2: İSTEĞE BAĞLI HOCAYA MESAJ / ÖZEL NOT
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.secondary, size: 20),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Hocaya Mesaj / Özel Not (İsteğe Bağlı)',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Öğretim görevlisine tesliminiz veya dosyalarınızla ilgili iletmek istediğiniz açıklama.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Hızlı Şablon Çipleri
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _quickNotes.map((note) {
                            return ActionChip(
                              label: Text(note, style: const TextStyle(fontSize: 11)),
                              backgroundColor: AppColors.surfaceHigh,
                              onPressed: () {
                                if (_noteController.text.isEmpty) {
                                  _noteController.text = note;
                                } else {
                                  _noteController.text = '${_noteController.text}\n$note';
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          enabled: !_isSubmitting,
                          decoration: const InputDecoration(
                            labelText: 'Mesajınız',
                            hintText: 'Hocam, ödev dosyalarını ve açıklamaları ekledim...',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Teslim Butonu
                FilledButton.icon(
                  onPressed: _isSubmitting || user == null
                      ? null
                      : () => _confirmAndSubmit(user.uid, user.fullName),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isSubmitting
                        ? 'Teslim Ediliyor...'
                        : isLate
                            ? 'Geç Teslim Et'
                            : 'Ödevi Teslim Et',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
