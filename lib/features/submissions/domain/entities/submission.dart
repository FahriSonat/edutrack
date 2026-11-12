// ==============================================================================
// 📌 DOSYA: lib/features/submissions/domain/entities/submission.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Öğrencinin bir ödeve yaptığı teslimi (Submission) temsil eden veri modeli.
// 📋 İÇERİK:
//   - Öğrenci kimlik ve adı (studentUid, studentName)
//   - Teslim zamanı ve gecikme durumu (submittedAt, isLate)
//   - GitHub repo & commit analizi (repoUrl, branch, latestCommitSha, commitCount vb.)
//   - Öğrencinin hocaya ilettiği özel not (note)
//   - Eklenen fiziki/dijital dosyalar (attachedFiles: SubmissionFile listesi)
//   - Notlandırma ve hoca geri bildirimi (score, feedback, gradedAt)
//   - Firestore serialization / deserialization (fromFirestore, toMap)
// ==============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'submission_file.dart';

/// Bir öğrencinin ödev teslim bilgilerini tutan ana domain varlığı.
class Submission {
  /// Öğrencinin benzersiz Firebase Auth UID'si (Firestore subcollection döküman ID'si)
  final String studentUid;

  /// Öğrencinin adı ve soyadı
  final String studentName;

  /// Ödevin sisteme teslim edildiği sunucu zaman damgası
  final DateTime submittedAt;

  /// Teslimin son tarihten sonra yapılıp yapılmadığı (Geç Teslim bayrağı)
  final bool isLate;

  /// Teslim edilen GitHub reposunun tam URL'i (isteğe bağlı)
  final String? repoUrl;

  /// Repo sahibi (GitHub username veya organization)
  final String? repoOwner;

  /// GitHub depo (repository) adı
  final String? repoName;

  /// Teslim edilen Git dalı (örn: main, master, develop)
  final String? branch;

  /// Teslim anındaki en son commit SHA hash değeri (örn: 7a9f2bc4)
  final String? latestCommitSha;

  /// Repo üzerindeki toplam commit sayısı
  final int? commitCount;

  /// Repodaki ilk commit'in atıldığı tarih
  final DateTime? firstCommitAt;

  /// Repodaki son commit'in atıldığı tarih
  final DateTime? lastCommitAt;

  /// Teslim bitiş tarihinden sonra atılan commit sayısı (kural ihlali takibi)
  final int? commitsAfterDeadline;

  /// Öğrencinin isteğe bağlı hocaya mesajı veya özel açıklaması
  final String? note;

  /// Öğrencinin yüklediği ek dosyalar (.pdf, .docx, .png vb.)
  final List<SubmissionFile> attachedFiles;

  /// Eğitmenin verdiği puan (0 - 100 veya maxScore)
  final int? score;

  /// Eğitmenin değerlendirme açıklaması veya geri bildirimi
  final String? feedback;

  /// Notlandırmanın tamamlandığı tarih
  final DateTime? gradedAt;

  const Submission({
    required this.studentUid,
    required this.studentName,
    required this.submittedAt,
    required this.isLate,
    this.repoUrl,
    this.repoOwner,
    this.repoName,
    this.branch,
    this.latestCommitSha,
    this.commitCount,
    this.firstCommitAt,
    this.lastCommitAt,
    this.commitsAfterDeadline,
    this.note,
    this.attachedFiles = const [],
    this.score,
    this.feedback,
    this.gradedAt,
  });

  /// Ödevin eğitmen tarafından puanlanıp puanlanmadığını döner
  bool get isGraded => score != null;

  /// Firestore dökümanından [Submission] nesnesi türeten fabrika kurucusu
  factory Submission.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawFiles = data['attachedFiles'] as List<dynamic>? ?? [];
    final files = rawFiles
        .map((f) => SubmissionFile.fromMap(f as Map<String, dynamic>))
        .toList();

    return Submission(
      studentUid: doc.id,
      studentName: data['studentName'] as String? ?? '',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isLate: data['isLate'] as bool? ?? false,
      repoUrl: data['repoUrl'] as String?,
      repoOwner: data['repoOwner'] as String?,
      repoName: data['repoName'] as String?,
      branch: data['branch'] as String?,
      latestCommitSha: data['latestCommitSha'] as String?,
      commitCount: (data['commitCount'] as num?)?.toInt(),
      firstCommitAt: (data['firstCommitAt'] as Timestamp?)?.toDate(),
      lastCommitAt: (data['lastCommitAt'] as Timestamp?)?.toDate(),
      commitsAfterDeadline: (data['commitsAfterDeadline'] as num?)?.toInt(),
      note: data['note'] as String?,
      attachedFiles: files,
      score: (data['score'] as num?)?.toInt(),
      feedback: data['feedback'] as String?,
      gradedAt: (data['gradedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firestore veritabanına yazılmak üzere Map formatına dönüştürür.
  /// Sunucu taraflı güvenli zaman damgası (FieldValue.serverTimestamp) kullanır.
  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'submittedAt': FieldValue.serverTimestamp(),
      'isLate': isLate,
      'repoUrl': repoUrl,
      'repoOwner': repoOwner,
      'repoName': repoName,
      'branch': branch,
      'latestCommitSha': latestCommitSha,
      'commitCount': commitCount,
      if (firstCommitAt != null) 'firstCommitAt': Timestamp.fromDate(firstCommitAt!),
      if (lastCommitAt != null) 'lastCommitAt': Timestamp.fromDate(lastCommitAt!),
      'commitsAfterDeadline': commitsAfterDeadline,
      'note': note,
      'attachedFiles': attachedFiles.map((f) => f.toMap()).toList(),
      'score': score,
      'feedback': feedback,
      if (gradedAt != null) 'gradedAt': Timestamp.fromDate(gradedAt!),
    };
  }
}
