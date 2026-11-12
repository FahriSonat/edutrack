// ==============================================================================
// 📌 DOSYA: lib/features/assignments/data/repositories/assignments_repository_impl.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: [AssignmentsRepository] domain sözleşmesinin somut uygulaması.
// 📋 İŞLEVLER:
//   - Firestore veri kaynağından gelen akışları UI'a yönlendirmek
//   - Asenkron çağrılarda oluşabilecek hataları yakalayıp [Result] monadı ile sarmalamak
//   - Presentation katmanını ham istisnalardan (exception) yalıtmak
// ==============================================================================

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/repositories/assignments_repository.dart';
import '../datasources/assignments_firestore_datasource.dart';

/// Ödev veri işlemlerini yürüten repository implementasyonu
class AssignmentsRepositoryImpl implements AssignmentsRepository {
  final AssignmentsFirestoreDataSource dataSource;

  AssignmentsRepositoryImpl(this.dataSource);

  /// Sınıf ödevleri akışını döner
  @override
  Stream<List<Assignment>> watchAssignmentsForClass(String classId) {
    return dataSource.watchAssignmentsForClass(classId);
  }

  /// Öğretmen ödevleri akışını döner
  @override
  Stream<List<Assignment>> watchAssignmentsForTeacher(String teacherId) {
    return dataSource.watchAssignmentsForTeacher(teacherId);
  }

  /// Tekil ödev bilgisini Result içinde döner
  @override
  Future<Result<Assignment?>> getAssignmentById(String assignmentId) async {
    try {
      final assignment = await dataSource.getAssignmentById(assignmentId);
      return Result.success(assignment);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Ödev alınamadı: $e'));
    }
  }

  /// Ödevi kaydeder ve üretilen ID'yi Result ile döner
  @override
  Future<Result<String>> createAssignment(Assignment assignment) async {
    try {
      final id = await dataSource.createAssignment(assignment);
      return Result.success(id);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Ödev kaydedilemedi: $e'));
    }
  }

  /// Ödev bilgilerini günceller
  @override
  Future<Result<void>> updateAssignment(Assignment assignment) async {
    try {
      await dataSource.updateAssignment(assignment);
      return Result.success(null);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Ödev güncellenemedi: $e'));
    }
  }

  /// Ödevi siler
  @override
  Future<Result<void>> deleteAssignment(String assignmentId) async {
    try {
      await dataSource.deleteAssignment(assignmentId);
      return Result.success(null);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(Failure(message: 'Ödev silinemedi: $e'));
    }
  }
}
