import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/widgets/assignment_vertical_card.dart';
import 'package:edutrack_app/core/demo/demo_data.dart';

void main() {
  group('AssignmentVerticalCard Widget Tests', () {
    testWidgets('renders all sample assignments inside carousel bounds (160x168) without overflow', (tester) async {
      for (final assignment in DemoData.sampleAssignments) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 168,
                width: 160,
                child: AssignmentVerticalCard(
                  width: 160,
                  assignment: assignment,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Overflow occurred for ${assignment.courseName}');
      }
    });
  });
}
