import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/widgets/sweet_progress_bar.dart';

void main() {
  group('SweetProgressBar Widget Tests', () {
    testWidgets('renders label, percent, and icon correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SweetProgressBar(
              progress: 0.75,
              label: 'Kalan Süre',
              subtitle: 'Son 2 gün kaldı',
            ),
          ),
        ),
      );

      expect(find.text('Kalan Süre'), findsOneWidget);
      expect(find.text('Son 2 gün kaldı'), findsOneWidget);
      expect(find.text('%75'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    });

    testWidgets('clamps progress between 0.0 and 1.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SweetProgressBar(
              progress: 1.5,
              label: 'Tamamlandı',
            ),
          ),
        ),
      );

      expect(find.text('%100'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
    });
  });
}

