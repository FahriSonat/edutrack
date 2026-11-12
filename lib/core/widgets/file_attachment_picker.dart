// ==============================================================================
// 📌 DOSYA: lib/core/widgets/file_attachment_picker.dart
// 📌 AÇIKLAMA: Ödev teslimlerinde ve ödev oluşturmada ek dosya (PDF, Word, resim)
//              seçimini, listelenmesini ve kaldırılmasını sağlayan UI bileşeni.
// ==============================================================================

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/submissions/domain/entities/submission_file.dart';

/// [FileAttachmentPicker], kullanıcıya dosya yükleme butonu ve seçilen dosyaların
/// silinebilir etiket/kart listesini sunar.
class FileAttachmentPicker extends StatelessWidget {
  final List<SubmissionFile> files;
  final ValueChanged<List<SubmissionFile>> onFilesChanged;
  final bool isEnabled;

  const FileAttachmentPicker({
    super.key,
    required this.files,
    required this.onFilesChanged,
    this.isEnabled = true,
  });

  Future<void> _pickFiles(BuildContext context) async {
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (picked.isNotEmpty) {
        final newFiles = <SubmissionFile>[];
        for (final f in picked) {
          final ext = f.extension?.toLowerCase() ?? 'file';
          final size = f.lengthSync() ?? (await f.length()) ?? 0;
          newFiles.add(
            SubmissionFile(
              name: f.name,
              path: f.path,
              size: size,
              extension: ext,
            ),
          );
        }

        final updatedList = List<SubmissionFile>.from(files)..addAll(newFiles);
        onFilesChanged(updatedList);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dosya seçilemedi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    final updatedList = List<SubmissionFile>.from(files)..removeAt(index);
    onFilesChanged(updatedList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Ek Dosyalar (.pdf, .doc, .jpg, .png)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            if (files.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${files.length} Dosya',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Ödev raporu, doküman veya ekran görüntülerinizi ekleyebilirsiniz.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Dosya Ekleme Buton Alanı
        InkWell(
          onTap: isEnabled ? () => _pickFiles(context) : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outline, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Dosya Seç veya Yükle',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Eklenen Dosyaların Listesi
        if (files.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          ...files.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            final (color, icon, label) = _getFileVisuals(file.extension);

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
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
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              file.formattedSize,
                              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isEnabled)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.onSurfaceVariant),
                      tooltip: 'Dosyayı Kaldır',
                      onPressed: () => _removeFile(index),
                    ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  (Color, IconData, String) _getFileVisuals(String ext) {
    return switch (ext.toLowerCase()) {
      'pdf' => (AppColors.error, Icons.picture_as_pdf_rounded, 'PDF'),
      'doc' || 'docx' => (AppColors.primary, Icons.description_rounded, 'WORD'),
      'jpg' || 'jpeg' || 'png' => (AppColors.success, Icons.image_rounded, 'GÖRSEL'),
      _ => (AppColors.secondary, Icons.insert_drive_file_rounded, ext.toUpperCase()),
    };
  }
}
