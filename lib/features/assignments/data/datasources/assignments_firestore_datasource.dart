// ==============================================================================
// 📌 DOSYA: lib/features/assignments/data/datasources/assignments_firestore_datasource.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Firestore `assignments` koleksiyonu ile doğrudan iletişim kurarak
//           ödev CRUD işlemlerini yürüten veri kaynağı (Data Source).
// 📋 İŞLEVLER:
//   - watchAssignmentsForClass: Öğrencinin sınıfına ait ödevleri son teslim tarihine göre dinler
//   - watchAssignmentsForTeacher: Eğitmenin oluşturduğu ödevleri oluşturma tarihine göre dinler
//   - getAssignmentById: Tekil ödev detayını çeker
//   - createAssignment: Yeni ödev dokümanı ekler
//   - updateAssignment: Var olan ödevi günceller
//   - deleteAssignment: Ödevi veritabanından siler
// ==============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/firebase/collections.dart';
import '../../domain/entities/assignment.dart';

/// Ödev Firestore veri kaynağı sözleşmesi
abstract class AssignmentsFirestoreDataSource {
  Stream<List<Assignment>> watchAssignmentsForClass(String classId);
  Stream<List<Assignment>> watchAssignmentsForTeacher(String teacherId);
  Future<Assignment?> getAssignmentById(String assignmentId);
  Future<String> createAssignment(Assignment assignment);
  Future<void> updateAssignment(Assignment assignment);
  Future<void> deleteAssignment(String assignmentId);
}

/// Firestore SDK kullanarak [AssignmentsFirestoreDataSource] arayüzünü uygulayan sınıf
class AssignmentsFirestoreDataSourceImpl implements AssignmentsFirestoreDataSource {
  final FirebaseFirestore firestore;

  AssignmentsFirestoreDataSourceImpl(this.firestore);

  /// `assignments` koleksiyon referansı
  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection(Collections.assignments);

  /// Sınıf kimliğine göre ödevleri sıralı akışla dinler
  @override
  Stream<List<Assignment>> watchAssignmentsForClass(String classId) {
    return _collection
        .where('classId', isEqualTo: classId)
        .orderBy('dueAt')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Assignment.fromFirestore(doc)).toList());
  }

  /// Öğretmen kimliğine göre açılan ödevleri tersten sıralı akışla dinler
  @override
  Stream<List<Assignment>> watchAssignmentsForTeacher(String teacherId) {
    return _collection
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Assignment.fromFirestore(doc)).toList());
  }

  /// Belirtilen ID'ye sahip ödev dokümanını çeker
  @override
  Future<Assignment?> getAssignmentById(String assignmentId) async {
    try {
      final doc = await _collection.doc(assignmentId).get();
      if (!doc.exists || doc.data() == null) return null;
      return Assignment.fromFirestore(doc);
    } catch (e) {
      throw Failure(message: 'Ödev bilgisi yüklenemedi: $e');
    }
  }

  /// Yeni bir ödev dokümanı oluşturur ve otomatik üretilen ID'yi döner
  @override
  Future<String> createAssignment(Assignment assignment) async {
    try {
      final docRef = await _collection.add(assignment.toMap());
      return docRef.id;
    } catch (e) {
      throw Failure(message: 'Ödev oluşturulamadı: $e');
    }
  }

  /// Var olan ödev dokümanının alanlarını günceller
  @override
  Future<void> updateAssignment(Assignment assignment) async {
    try {
      await _collection.doc(assignment.id).update(assignment.toMap());
    } catch (e) {
      throw Failure(message: 'Ödev güncellenemedi: $e');
    }
  }

  /// Ödev dokümanını siler
  @override
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _collection.doc(assignmentId).delete();
    } catch (e) {
      throw Failure(message: 'Ödev silinemedi: $e');
    }
  }
}
