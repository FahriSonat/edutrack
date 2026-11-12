import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/widgets/file_attachment_picker.dart';
import 'package:edutrack_app/features/submissions/domain/entities/submission_file.dart';

void main() {
  group('FileAttachmentPicker Widget Tests', () {
    testWidgets('renders empty state with upload button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileAttachmentPicker(
              files: const [],
              onFilesChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Ek Dosyalar (.pdf, .doc, .jpg, .png)'), findsOneWidget);
      expect(find.text('Dosya Seç veya Yükle'), findsOneWidget);
    });

    testWidgets('renders list of files and triggers removal', (tester) async {
      List<SubmissionFile> currentFiles = [
        const SubmissionFile(name: 'rapor.pdf', size: 1024 * 50, extension: 'pdf'),
        const SubmissionFile(name: 'ekran.png', size: 1024 * 120, extension: 'png'),
      ];

      List<SubmissionFile>? changedFiles;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileAttachmentPicker(
              files: currentFiles,
              onFilesChanged: (files) => changedFiles = files,
            ),
          ),
        ),
      );

      expect(find.text('rapor.pdf'), findsOneWidget);
      expect(find.text('ekran.png'), findsOneWidget);
      expect(find.text('2 Dosya'), findsOneWidget);

      // Remove the first file (rapor.pdf)
      final removeButtons = find.byIcon(Icons.close_rounded);
      expect(removeButtons, findsNWidgets(2));

      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();

      expect(changedFiles, isNotNull);
      expect(changedFiles!.length, 1);
      expect(changedFiles!.first.name, 'ekran.png');
    });
  });
}

