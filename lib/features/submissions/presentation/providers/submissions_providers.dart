// ==============================================================================
// 📌 DOSYA: lib/features/submissions/presentation/providers/submissions_providers.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Ödev teslimleri ve notlandırma modülü için Riverpod sağlayıcıları.
// 📋 İÇERİK:
//   - submissionsFirestoreDataSourceProvider: Teslim Firestore veri kaynağı
//   - submissionsRepositoryProvider: Teslim repository somut örneği
//   - studentSubmissionProvider: Öğrenci ve ödev bazlı tekil teslim akışı (Record tipi argüman)
//   - assignmentSubmissionsProvider: Bir ödeve yapılan tüm teslimler akışı (Eğitmen için)
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/firebase/firebase_providers.dart';
import '../../data/datasources/submissions_firestore_datasource.dart';
import '../../data/repositories/submissions_repository_impl.dart';
import '../../domain/entities/submission.dart';
import '../../domain/repositories/submissions_repository.dart';

/// Ödev teslimleri Firestore veri kaynağı sağlayıcısı
final submissionsFirestoreDataSourceProvider =
    Provider<SubmissionsFirestoreDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return SubmissionsFirestoreDataSourceImpl(firestore);
});

/// Ödev teslimleri repository sağlayıcısı
final submissionsRepositoryProvider = Provider<SubmissionsRepository>((ref) {
  final dataSource = ref.watch(submissionsFirestoreDataSourceProvider);
  return SubmissionsRepositoryImpl(dataSource);
});

/// Belirli bir öğrencinin belirli bir ödeve ait teslimini anlık dinleyen sağlayıcı
final studentSubmissionProvider = StreamProvider.family<Submission?,
    ({String assignmentId, String studentUid})>((ref, arg) {
  final repository = ref.watch(submissionsRepositoryProvider);
  return repository.watchSubmission(
    assignmentId: arg.assignmentId,
    studentUid: arg.studentUid,
  );
});

/// Bir ödeve yapılmış tüm teslimleri anlık dinleyen sağlayıcı (Eğitmen ekranı)
final assignmentSubmissionsProvider =
    StreamProvider.family<List<Submission>, String>((ref, assignmentId) {
  final repository = ref.watch(submissionsRepositoryProvider);
  return repository.watchSubmissionsForAssignment(assignmentId);
});
