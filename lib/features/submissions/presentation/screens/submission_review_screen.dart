// ==============================================================================
// 📌 DOSYA: lib/features/submissions/presentation/screens/submission_review_screen.dart
// 📌 AÇIKLAMA: Öğretmenin öğrenci teslimini incelediği, GitHub commit kanıtlarını
//              ve zaman damgalarını gördüğü, puan ve geri bildirim verdiği ekran.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/commit_tile.dart';
import '../../../../core/widgets/repo_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../assignments/domain/entities/assignment.dart';
import '../../../github/domain/entities/repo_analysis.dart';
import '../../../github/presentation/providers/github_providers.dart';
import '../../domain/entities/submission.dart';
import '../providers/submissions_providers.dart';

/// [SubmissionReviewScreen], öğretmen tarafında teslim detaylarını ve puanlamayı yönetir.
class SubmissionReviewScreen extends ConsumerStatefulWidget {
  final Assignment assignment;
  final Submission submission;

  const SubmissionReviewScreen({
    super.key,
    required this.assignment,
    required this.submission,
  });

  @override
  ConsumerState<SubmissionReviewScreen> createState() => _SubmissionReviewScreenState();
}

class _SubmissionReviewScreenState extends ConsumerState<SubmissionReviewScreen> {
  final _scoreController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _isSaving = false;
  List<GithubCommit> _commits = [];
  bool _isLoadingCommits = false;

  @override
  void initState() {
    super.initState();
    if (widget.submission.score != null) {
      _scoreController.text = widget.submission.score.toString();
    }
    if (widget.submission.feedback != null) {
      _feedbackController.text = widget.submission.feedback!;
    }
    _loadCommits();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadCommits() async {
    final owner = widget.submission.repoOwner;
    final repo = widget.submission.repoName;
    if (owner == null || repo == null) return;

    setState(() => _isLoadingCommits = true);
    final githubRepo = ref.read(githubRepositoryProvider);
    final result = await githubRepo.getCommits(
      owner: owner,
      repo: repo,
      branch: widget.submission.branch,
      dueAt: widget.assignment.dueAt,
    );

    if (!mounted) return;
    setState(() {
      _commits = result.dataOrNull ?? [];
      _isLoadingCommits = false;
    });
  }

  Future<void> _saveGrade() async {
    final score = int.tryParse(_scoreController.text.trim());
    if (score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir not giriniz.')),
      );
      return;
    }

    if (score < 0 || score > widget.assignment.maxScore) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not 0 ile ${widget.assignment.maxScore} arasında olmalıdır.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final repository = ref.read(submissionsRepositoryProvider);
    final result = await repository.gradeSubmission(
      assignmentId: widget.assignment.id,
      studentUid: widget.submission.studentUid,
      score: score,
      feedback: _feedbackController.text.trim().isNotEmpty
          ? _feedbackController.text.trim()
          : null,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not ve değerlendirme kaydedildi!'),
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
    final sub = widget.submission;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('submission_review_back_button'),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${sub.studentName} — Teslim'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Öğrenci & Teslim Durum Özeti Kartı (Soft Stille)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sub.studentName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        StatusChip(
                          status: sub.isLate
                              ? StatusType.lateSubmission
                              : StatusType.submitted,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resmi Teslim Saati (Sunucu):',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          AppDateUtils.formatDateTime(sub.submittedAt),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ödev Bitiş Tarihi:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                        Text(AppDateUtils.formatDateTime(widget.assignment.dueAt)),
                      ],
                    ),
                    if (sub.isLate && widget.assignment.latePenaltyPercent != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.warningSoft.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'ℹ️ Gecikmeli teslim: Öngörülen ceza kesintisi %${widget.assignment.latePenaltyPercent}',
                          style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ÖĞRENCİNİN HOCAYA MESAJI (İsteğe Bağlı Gönderilen Not)
            if (sub.note != null && sub.note!.isNotEmpty) ...[
              Card(
                color: AppColors.surfaceSubtle,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.chat_bubble_rounded, color: AppColors.secondary, size: 18),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Öğrencinin Size İlettiği Mesaj:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          sub.note!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // EKLENEN DOSYALAR (.pdf, .doc, .jpg, .png)
            if (sub.attachedFiles.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.attach_file_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Öğrencinin Eklediği Dosyalar (${sub.attachedFiles.length})',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...sub.attachedFiles.map((file) {
                        final ext = file.extension.toLowerCase();
                        final (color, icon) = switch (ext) {
                          'pdf' => (AppColors.error, Icons.picture_as_pdf_rounded),
                          'doc' || 'docx' => (AppColors.primary, Icons.description_rounded),
                          'jpg' || 'jpeg' || 'png' => (AppColors.success, Icons.image_rounded),
                          _ => (AppColors.secondary, Icons.insert_drive_file_rounded),
                        };

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineSoft, width: 0.8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      file.formattedSize,
                                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${file.name} dosyası açılıyor...')),
                                  );
                                },
                                icon: const Icon(Icons.download_rounded, size: 16),
                                label: const Text('İndir / Aç', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(60, 32),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Repo Kartı (Varsa)
            if (sub.repoOwner != null && sub.repoName != null) ...[
              RepoCard(
                owner: sub.repoOwner!,
                repo: sub.repoName!,
                branch: sub.branch,
                repoUrl: sub.repoUrl,
              ),
              const SizedBox(height: AppSpacing.md),

              // Commit Kanıt Özeti
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.commit_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'GitHub Commit Kanıtları',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Toplam Commit: ${sub.commitCount ?? "-"}'),
                          if ((sub.commitsAfterDeadline ?? 0) > 0)
                            Text(
                              'Süre Sonrası Commit: ${sub.commitsAfterDeadline}',
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
                      if (sub.lastCommitAt != null)
                        Text('Son Commit Zamanı: ${AppDateUtils.formatDateTime(sub.lastCommitAt)}'),
                      if (sub.latestCommitSha != null)
                        Text(
                          'Teslim Anındaki SHA: ${sub.latestCommitSha}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ),

              if (_isLoadingCommits)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_commits.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Commit Geçmişi (Son 10)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                ..._commits.take(10).map(
                      (c) => CommitTile(
                        sha: c.sha,
                        message: c.message,
                        date: c.date,
                        isAfterDeadline: c.isAfterDeadline,
                      ),
                    ),
              ],
            ],

            const SizedBox(height: AppSpacing.lg),

            // Notlama ve Geri Bildirim Formu (Soft Stille)
            Card(
              color: AppColors.surfaceHigh,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notlama ve Değerlendirme',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _scoreController,
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.numberInRange(v, min: 0, max: widget.assignment.maxScore),
                      decoration: InputDecoration(
                        labelText: 'Puan (0 - ${widget.assignment.maxScore})',
                        prefixIcon: const Icon(Icons.grade_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _feedbackController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Öğretmen Geri Bildirimi',
                        hintText: 'Öğrenciye notla ilgili açıklama veya tavsiye...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _saveGrade,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        _isSaving ? 'Kaydediliyor...' : 'Notu Kaydet ve Yayınla',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
