import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/widgets/bouncy_card.dart';

void main() {
  group('BouncyCard Widget Tests', () {
    testWidgets('renders child content and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BouncyCard(
              onTap: () => tapped = true,
              child: const Text('Bouncy İçerik'),
            ),
          ),
        ),
      );

      expect(find.text('Bouncy İçerik'), findsOneWidget);

      await tester.tap(find.text('Bouncy İçerik'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}

