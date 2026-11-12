import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/features/assignments/domain/entities/assignment.dart';
import 'package:edutrack_app/features/assignments/domain/entities/late_policy.dart';

void main() {
  group('LatePolicy & SubmissionState Tests', () {
    final now = DateTime(2026, 11, 11, 12, 0);

    test('when now is before dueAt, state is open', () {
      final assignment = Assignment(
        id: '1',
        offeringId: 'o1',
        classId: 'c1',
        teacherId: 't1',
        courseName: 'Mobil Programlama',
        title: 'Ödev 1',
        description: 'Flutter UI',
        maxScore: 100,
        createdAt: now.subtract(const Duration(days: 7)),
        dueAt: now.add(const Duration(hours: 2)), // Gelecekte
        latePolicy: LatePolicy.closed,
      );

      expect(assignment.getSubmissionState(now), SubmissionState.open);
    });

    test('when dueAt passed and policy is closed, state is closed', () {
      final assignment = Assignment(
        id: '2',
        offeringId: 'o1',
        classId: 'c1',
        teacherId: 't1',
        courseName: 'Mobil Programlama',
        title: 'Ödev 2',
        description: 'Flutter UI',
        maxScore: 100,
        createdAt: now.subtract(const Duration(days: 7)),
        dueAt: now.subtract(const Duration(hours: 1)), // Geçmiş
        latePolicy: LatePolicy.closed,
      );

      expect(assignment.getSubmissionState(now), SubmissionState.closed);
    });

    test('when dueAt passed and policy is allowLate within lateUntil, state is late', () {
      final assignment = Assignment(
        id: '3',
        offeringId: 'o1',
        classId: 'c1',
        teacherId: 't1',
        courseName: 'Mobil Programlama',
        title: 'Ödev 3',
        description: 'Flutter UI',
        maxScore: 100,
        createdAt: now.subtract(const Duration(days: 7)),
        dueAt: now.subtract(const Duration(hours: 1)),
        latePolicy: LatePolicy.allowLate,
        latePenaltyPercent: 20,
        lateUntil: now.add(const Duration(days: 2)), // lateUntil henüz gelmedi
      );

      expect(assignment.getSubmissionState(now), SubmissionState.late);
    });

    test('when dueAt passed and policy is allowLate but lateUntil also passed, state is closed', () {
      final assignment = Assignment(
        id: '4',
        offeringId: 'o1',
        classId: 'c1',
        teacherId: 't1',
        courseName: 'Mobil Programlama',
        title: 'Ödev 4',
        description: 'Flutter UI',
        maxScore: 100,
        createdAt: now.subtract(const Duration(days: 7)),
        dueAt: now.subtract(const Duration(days: 3)),
        latePolicy: LatePolicy.allowLate,
        latePenaltyPercent: 20,
        lateUntil: now.subtract(const Duration(hours: 1)), // lateUntil de geçti
      );

      expect(assignment.getSubmissionState(now), SubmissionState.closed);
    });
  });
}

