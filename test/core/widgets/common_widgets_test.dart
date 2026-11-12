import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/widgets/status_chip.dart';
import 'package:edutrack_app/core/widgets/deadline_badge.dart';

void main() {
  group('Common Widgets Tests', () {
    testWidgets('StatusChip renders correct labels for each status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusChip(status: StatusType.open),
                StatusChip(status: StatusType.submitted),
                StatusChip(status: StatusType.lateSubmission),
                StatusChip(status: StatusType.closed),
                StatusChip(status: StatusType.graded),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Açık'), findsOneWidget);
      expect(find.text('Teslim Edildi'), findsOneWidget);
      expect(find.text('Geç Teslim'), findsOneWidget);
      expect(find.text('Kapalı'), findsOneWidget);
      expect(find.text('Notlandı'), findsOneWidget);
    });

    testWidgets('DeadlineBadge renders remaining time correctly', (tester) async {
      final now = DateTime(2026, 11, 11, 12, 0);
      final futureDeadline = now.add(const Duration(hours: 3));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeadlineBadge(
              deadline: futureDeadline,
              now: now,
            ),
          ),
        ),
      );

      expect(find.text('3 saat kaldı'), findsOneWidget);
    });
  });
}

