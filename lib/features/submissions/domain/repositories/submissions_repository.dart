// ==============================================================================
// 📌 DOSYA: lib/features/submissions/domain/repositories/submissions_repository.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Öğrenci teslimatlarının kaydedilmesi, izlenmesi ve eğitmen tarafından
//           notlandırılması işlemlerini soyutlayan domain repository arayüzü.
// 📋 İŞLEVLER:
//   - submit: Öğrencinin ödev teslimini kaydetme / güncelleme
//   - watchSubmission: Belirli bir öğrencinin teslim durumunu anlık dinleme
//   - watchSubmissionsForAssignment: Bir ödeve gelen tüm teslimleri eğitmen için listeleme
//   - gradeSubmission: Eğitmenin puantaj ve yazılı geri bildirim kaydetmesi
// ==============================================================================

import '../../../../core/error/result.dart';
import '../../domain/entities/submission.dart';

/// Ödev teslim ve değerlendirme işlemlerinin soyut arayüzü.
abstract class SubmissionsRepository {
  /// Öğrencinin hazırladığı teslimi Firestore'a gönderir
  Future<Result<void>> submit({
    required String assignmentId,
    required Submission submission,
  });

  /// Belirli bir ödev için ilgili öğrencinin teslimini gerçek zamanlı akışla döner
  Stream<Submission?> watchSubmission({
    required String assignmentId,
    required String studentUid,
  });

  /// Belirtilen ödeve yapılmış tüm teslimleri gerçek zamanlı akışla döner (Eğitmen ekranı)
  Stream<List<Submission>> watchSubmissionsForAssignment(String assignmentId);

  /// Eğitmenin öğrenci teslimine puan ve açıklama vermesini sağlar
  Future<Result<void>> gradeSubmission({
    required String assignmentId,
    required String studentUid,
    required int score,
    String? feedback,
  });
}
