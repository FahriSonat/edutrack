// ==============================================================================
// 📌 DOSYA: lib/features/assignments/presentation/providers/assignments_providers.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Ödev yönetimi modülüne ait Riverpod bağımlılık enjeksiyonu ve durum
//           sağlayıcılarını (State Providers) tanımlar.
// 📋 İÇERİK:
//   - assignmentsFirestoreDataSourceProvider: Firestore veri kaynağı
//   - assignmentsRepositoryProvider: Repository somut örneği
//   - classAssignmentsProvider: Sınıfa ait ödevleri sağlayan StreamProvider.family
//   - teacherAssignmentsProvider: Eğitmene ait ödevleri sağlayan StreamProvider.family
//   - assignmentDetailProvider: Tekil ödev detayını çeken FutureProvider.family
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/firebase/firebase_providers.dart';
import '../../data/datasources/assignments_firestore_datasource.dart';
import '../../data/repositories/assignments_repository_impl.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/repositories/assignments_repository.dart';

/// Ödev Firestore veri kaynağı sağlayıcısı
final assignmentsFirestoreDataSourceProvider =
    Provider<AssignmentsFirestoreDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return AssignmentsFirestoreDataSourceImpl(firestore);
});

/// Ödev repository sağlayıcısı
final assignmentsRepositoryProvider = Provider<AssignmentsRepository>((ref) {
  final dataSource = ref.watch(assignmentsFirestoreDataSourceProvider);
  return AssignmentsRepositoryImpl(dataSource);
});

/// Bir sınıfa atanmış ödevleri gerçek zamanlı akışla sunan sağlayıcı
final classAssignmentsProvider =
    StreamProvider.family<List<Assignment>, String>((ref, classId) {
  final repository = ref.watch(assignmentsRepositoryProvider);
  return repository.watchAssignmentsForClass(classId);
});

/// Belirli bir eğitmenin oluşturduğu ödevleri gerçek zamanlı akışla sunan sağlayıcı
final teacherAssignmentsProvider =
    StreamProvider.family<List<Assignment>, String>((ref, teacherId) {
  final repository = ref.watch(assignmentsRepositoryProvider);
  return repository.watchAssignmentsForTeacher(teacherId);
});

/// ID ile tekil bir ödevin detaylarını getiren sağlayıcı
final assignmentDetailProvider =
    FutureProvider.family<Assignment?, String>((ref, assignmentId) {
  final repository = ref.watch(assignmentsRepositoryProvider);
  return repository.getAssignmentById(assignmentId).then((res) => res.dataOrNull);
});
