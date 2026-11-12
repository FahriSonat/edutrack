// ==============================================================================
// 📌 DOSYA: lib/features/submissions/data/repositories/submissions_repository_impl.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: [SubmissionsRepository] domain sözleşmesinin somut uygulaması.
// 📋 İŞLEVLER:
//   - Firestore veri kaynağı çağrılarını yürütmek
//   - Teslim gönderme ve notlandırma sonuçlarını [Result] nesnelerine dönüştürmek
// ==============================================================================

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/submission.dart';
import '../../domain/repositories/submissions_repository.dart';
import '../datasources/submissions_firestore_datasource.dart';

/// Ödev teslim ve puanlama işlemlerini yürüten repository implementasyonu
class SubmissionsRepositoryImpl implements SubmissionsRepository {
  final SubmissionsFirestoreDataSource dataSource;

  SubmissionsRepositoryImpl(this.dataSource);

  /// Öğrenci ödev teslimini kaydeder
  @override
  Future<Result<void>> submit({
    required String assignmentId,
    required Submission submission,
  }) async {
    try {
      await dataSource.submit(
        assignmentId: assignmentId,
        submission: submission,
      );
      return Result.success(null);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Ödev teslim edilemedi: $e'));
    }
  }

  /// Belirli bir öğrencinin teslim dökümanını izler
  @override
  Stream<Submission?> watchSubmission({
    required String assignmentId,
    required String studentUid,
  }) {
    return dataSource.watchSubmission(
      assignmentId: assignmentId,
      studentUid: studentUid,
    );
  }

  /// Bir ödeve gelen tüm teslimleri izler
  @override
  Stream<List<Submission>> watchSubmissionsForAssignment(String assignmentId) {
    return dataSource.watchSubmissionsForAssignment(assignmentId);
  }

  /// Öğrenci teslimini puanlar ve hoca notunu kaydeder
  @override
  Future<Result<void>> gradeSubmission({
    required String assignmentId,
    required String studentUid,
    required int score,
    String? feedback,
  }) async {
    try {
      await dataSource.gradeSubmission(
        assignmentId: assignmentId,
        studentUid: studentUid,
        score: score,
        feedback: feedback,
      );
      return Result.success(null);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Not kaydedilemedi: $e'));
    }
  }
}
