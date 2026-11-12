// ==============================================================================
// 📌 DOSYA: lib/features/submissions/domain/entities/submission_file.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Öğrencinin ödev teslimine eklediği yerel/harici dosya eklerini temsil eder.
// 📋 İÇERİK:
//   - Dosya adı, yerel yolu, boyutu (bayt) ve uzantısı (.pdf, .png vb.)
//   - formattedSize: Kullanıcı dostu okunabilir boyut metni (KB, MB hesaplayıcı)
//   - fromMap / toMap serileştirme metodları
// ==============================================================================

/// Ödev teslimine iliştirilen bir dosya ekini tanımlayan model sınıfı.
class SubmissionFile {
  /// Dosyanın tam adı (örn: Proje_Raporu.pdf)
  final String name;

  /// Cihaz üzerindeki geçici yerel dosya yolu (varsa)
  final String? path;

  /// Dosyanın bayt cinsinden büyüklüğü
  final int size;

  /// Dosya uzantısı (örn: 'pdf', 'png', 'docx')
  final String extension;

  const SubmissionFile({
    required this.name,
    this.path,
    required this.size,
    required this.extension,
  });

  /// Kullanıcı arayüzünde gösterilmek üzere okunabilir dosya boyutu (B, KB, MB)
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// JSON / Map nesnesinden [SubmissionFile] türetir
  factory SubmissionFile.fromMap(Map<String, dynamic> map) {
    return SubmissionFile(
      name: map['name'] as String? ?? 'dosya',
      path: map['path'] as String?,
      size: (map['size'] as num?)?.toInt() ?? 0,
      extension: map['extension'] as String? ?? 'file',
    );
  }

  /// Firestore dokümanına gömülmek üzere Map formatına çevirir
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
      'size': size,
      'extension': extension,
    };
  }
}
