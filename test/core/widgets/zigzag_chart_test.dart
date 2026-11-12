import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/widgets/zigzag_chart.dart';

void main() {
  group('ZigzagChartWidget Tests', () {
    testWidgets('renders title, subtitle and custom paint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZigzagChartWidget(
              dataPoints: [10, 25, 15, 30, 20],
              title: 'Zikzak Başarı Grafiği',
              subtitle: 'Haftalık ritim',
            ),
          ),
        ),
      );

      expect(find.text('Zikzak Başarı Grafiği'), findsOneWidget);
      expect(find.text('Haftalık ritim'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}

