import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/features/submissions/domain/entities/submission_file.dart';

void main() {
  group('SubmissionFile Tests', () {
    test('formattedSize formats bytes, KB and MB correctly', () {
      const bytesFile = SubmissionFile(name: 'test.txt', size: 500, extension: 'txt');
      expect(bytesFile.formattedSize, '500 B');

      const kbFile = SubmissionFile(name: 'rapor.pdf', size: 1024 * 250, extension: 'pdf');
      expect(kbFile.formattedSize, '250.0 KB');

      const mbFile = SubmissionFile(name: 'video.mp4', size: 1024 * 1024 * 3, extension: 'mp4');
      expect(mbFile.formattedSize, '3.0 MB');
    });

    test('fromMap and toMap serialize correctly', () {
      const file = SubmissionFile(
        name: 'proje.docx',
        path: '/storage/proje.docx',
        size: 15400,
        extension: 'docx',
      );

      final map = file.toMap();
      expect(map['name'], 'proje.docx');
      expect(map['extension'], 'docx');
      expect(map['size'], 15400);

      final fromMap = SubmissionFile.fromMap(map);
      expect(fromMap.name, 'proje.docx');
      expect(fromMap.extension, 'docx');
      expect(fromMap.size, 15400);
    });
  });
}

