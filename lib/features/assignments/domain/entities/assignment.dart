// ==============================================================================
// 📌 DOSYA: lib/features/assignments/domain/entities/assignment.dart
// 📌 AÇIKLAMA: Ödev veri modelini (Domain Entity) temsil eden sınıf.
//              Ödev başlığı, açıklaması, son teslim tarihi ve geç teslim politikası
//              kurallarını (getSubmissionState) barındırır.
// ==============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'late_policy.dart';

/// [Assignment], bir ders kapsamında verilen ödevin tüm meta verilerini tutar.
class Assignment {
  final String id;
  final String offeringId;
  final String classId;
  final String teacherId;
  final String courseName;
  final String title;
  final String description;
  final int maxScore;
  final DateTime createdAt;
  final DateTime dueAt;
  final bool requiresRepo;
  final LatePolicy latePolicy;
  final int? latePenaltyPercent;
  final DateTime? lateUntil;

  const Assignment({
    required this.id,
    required this.offeringId,
    required this.classId,
    required this.teacherId,
    required this.courseName,
    required this.title,
    required this.description,
    required this.maxScore,
    required this.createdAt,
    required this.dueAt,
    this.requiresRepo = true,
    this.latePolicy = LatePolicy.closed,
    this.latePenaltyPercent,
    this.lateUntil,
  });

  SubmissionState getSubmissionState([DateTime? now]) {
    final current = now ?? DateTime.now();
    if (current.isBefore(dueAt)) return SubmissionState.open;
    if (latePolicy == LatePolicy.closed) return SubmissionState.closed;
    if (lateUntil != null && current.isAfter(lateUntil!)) return SubmissionState.closed;
    return SubmissionState.late;
  }

  factory Assignment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Assignment(
      id: doc.id,
      offeringId: data['offeringId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      teacherId: data['teacherId'] as String? ?? '',
      courseName: data['courseName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      maxScore: (data['maxScore'] as num?)?.toInt() ?? 100,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueAt: (data['dueAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      requiresRepo: data['requiresRepo'] as bool? ?? true,
      latePolicy: LatePolicy.fromString(data['latePolicy'] as String?),
      latePenaltyPercent: (data['latePenaltyPercent'] as num?)?.toInt(),
      lateUntil: (data['lateUntil'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'offeringId': offeringId,
      'classId': classId,
      'teacherId': teacherId,
      'courseName': courseName,
      'title': title,
      'description': description,
      'maxScore': maxScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueAt': Timestamp.fromDate(dueAt),
      'requiresRepo': requiresRepo,
      'latePolicy': latePolicy.asString,
      'latePenaltyPercent': latePenaltyPercent,
      if (lateUntil != null) 'lateUntil': Timestamp.fromDate(lateUntil!),
    };
  }
}

