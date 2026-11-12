// ==============================================================================
// 📌 DOSYA: lib/features/assignments/domain/repositories/assignments_repository.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Ödev yönetimi işlemlerini soyutlayan domain repository arayüzü.
// 📋 İŞLEVLER:
//   - watchAssignmentsForClass: Öğrencinin sınıfına ait ödevleri anlık izleme
//   - watchAssignmentsForTeacher: Eğitmenin oluşturduğu ödevleri anlık izleme
//   - getAssignmentById: Tekil bir ödevin detaylarını getirme
//   - createAssignment: Yeni ödev oluşturma
//   - updateAssignment: Var olan ödevi güncelleme
//   - deleteAssignment: Ödevi sistemden silme
// ==============================================================================

import '../../../../core/error/result.dart';
import '../../domain/entities/assignment.dart';

/// Ödev veri işlemlerini soyutlayan repository sözleşmesi.
abstract class AssignmentsRepository {
  /// Belirli bir sınıfa atanmış aktif ödevleri son teslim tarihine göre sıralı akışla döner
  Stream<List<Assignment>> watchAssignmentsForClass(String classId);

  /// Eğitmenin oluşturduğu ödevleri oluşturulma tarihine göre tersten sıralı akışla döner
  Stream<List<Assignment>> watchAssignmentsForTeacher(String teacherId);

  /// ID'si verilen ödevin detaylarını getirir
  Future<Result<Assignment?>> getAssignmentById(String assignmentId);

  /// Yeni bir ödev kaydı açar ve üretilen ID'yi döner
  Future<Result<String>> createAssignment(Assignment assignment);

  /// Var olan ödev bilgilerini günceller
  Future<Result<void>> updateAssignment(Assignment assignment);

  /// Ödevi ve bağlı kayıtları siler
  Future<Result<void>> deleteAssignment(String assignmentId);
}
