import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/widgets/assignment_ticket_card.dart';
import 'package:edutrack_app/core/demo/demo_data.dart';

void main() {
  group('AssignmentTicketCard Widget Tests', () {
    testWidgets('renders assignment title, course name and responds to tap', (tester) async {
      bool tapped = false;
      final assignment = DemoData.sampleAssignments.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssignmentTicketCard(
              assignment: assignment,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text(assignment.title), findsOneWidget);
      expect(find.text(assignment.courseName), findsOneWidget);

      await tester.tap(find.text(assignment.title));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}

