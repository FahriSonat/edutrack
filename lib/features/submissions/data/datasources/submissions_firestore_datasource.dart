// ==============================================================================
// 📌 DOSYA: lib/features/submissions/data/datasources/submissions_firestore_datasource.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Firestore `assignments/{assignmentId}/submissions/{studentUid}` alt koleksiyonu
//           (subcollection) ile doğrudan iletişim kuran veri kaynağı.
// 📋 İŞLEVLER:
//   - submit: Öğrencinin teslimini FieldValue.serverTimestamp() ile kaydetme
//   - watchSubmission: Belirli bir öğrencinin teslim dokümanını anlık izleme
//   - watchSubmissionsForAssignment: Bir ödev altındaki tüm teslimleri teslim tarihine
//     göre azalan sırada dinleme (Eğitmen için)
//   - gradeSubmission: Eğitmenin not (score) ve geri bildirim (feedback) girmesi
// ==============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/firebase/collections.dart';
import '../../domain/entities/submission.dart';

/// Ödev teslimleri Firestore veri kaynağı sözleşmesi
abstract class SubmissionsFirestoreDataSource {
  Future<void> submit({
    required String assignmentId,
    required Submission submission,
  });

  Stream<Submission?> watchSubmission({
    required String assignmentId,
    required String studentUid,
  });

  Stream<List<Submission>> watchSubmissionsForAssignment(String assignmentId);

  Future<void> gradeSubmission({
    required String assignmentId,
    required String studentUid,
    required int score,
    String? feedback,
  });
}

/// Firestore alt koleksiyon erişimlerini gerçekleştiren somut sınıf
class SubmissionsFirestoreDataSourceImpl implements SubmissionsFirestoreDataSource {
  final FirebaseFirestore firestore;

  SubmissionsFirestoreDataSourceImpl(this.firestore);

  /// Tekil teslim döküman referansı: `assignments/{assignmentId}/submissions/{studentUid}`
  DocumentReference<Map<String, dynamic>> _submissionDoc(
          String assignmentId, String studentUid) =>
      firestore
          .collection(Collections.assignments)
          .doc(assignmentId)
          .collection(Collections.submissions)
          .doc(studentUid);

  /// Ödeve ait tüm teslimler koleksiyonu: `assignments/{assignmentId}/submissions`
  CollectionReference<Map<String, dynamic>> _submissionsCol(String assignmentId) =>
      firestore
          .collection(Collections.assignments)
          .doc(assignmentId)
          .collection(Collections.submissions);

  /// Öğrencinin teslimini Firestore'a yazar
  @override
  Future<void> submit({
    required String assignmentId,
    required Submission submission,
  }) async {
    try {
      final docRef = _submissionDoc(assignmentId, submission.studentUid);
      // serverTimestamp() zorunlu kuralı ile dökümanı birleştirerek (merge) kaydet
      await docRef.set(submission.toMap(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const Failure(
          message: 'Teslim reddedildi. Ödevin süresi dolmuş veya geç teslim kuralları ihlal edilmiş olabilir.',
          code: 'permission-denied',
        );
      }
      throw Failure(message: 'Ödev teslim edilemedi: ${e.message ?? e.code}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(message: 'Ödev teslim edilirken hata oluştu: $e');
    }
  }

  /// Belirli bir öğrencinin teslim durumunu anlık dinler
  @override
  Stream<Submission?> watchSubmission({
    required String assignmentId,
    required String studentUid,
  }) {
    return _submissionDoc(assignmentId, studentUid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Submission.fromFirestore(doc);
    });
  }

  /// Bir ödeve yapılmış tüm teslimleri azalan tarihe göre sıralı akışla döner
  @override
  Stream<List<Submission>> watchSubmissionsForAssignment(String assignmentId) {
    return _submissionsCol(assignmentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Submission.fromFirestore(doc)).toList());
  }

  /// Eğitmenin verdiği puanı ve geri bildirimi kaydeder
  @override
  Future<void> gradeSubmission({
    required String assignmentId,
    required String studentUid,
    required int score,
    String? feedback,
  }) async {
    try {
      await _submissionDoc(assignmentId, studentUid).update({
        'score': score,
        'feedback': feedback,
        'gradedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Failure(message: 'Not kaydedilemedi: $e');
    }
  }
}
