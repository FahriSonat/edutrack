import 'package:flutter_test/flutter_test.dart';
import 'package:edutrack_app/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils Tests', () {
    final baseTime = DateTime(2026, 11, 11, 14, 30);

    test('formatDateTime formats correctly', () {
      expect(AppDateUtils.formatDateTime(null), '-');
      final formatted = AppDateUtils.formatDateTime(baseTime);
      expect(formatted, contains('11.11.2026'));
      expect(formatted, contains('14:30'));
    });

    test('remainingTimeText shows expired when deadline is past', () {
      final past = baseTime.subtract(const Duration(minutes: 5));
      expect(AppDateUtils.remainingTimeText(past, baseTime), 'Süre doldu');
    });

    test('remainingTimeText shows days and hours remaining', () {
      final future = baseTime.add(const Duration(days: 2, hours: 3));
      final text = AppDateUtils.remainingTimeText(future, baseTime);
      expect(text, '2 gün 3 saat kaldı');
    });

    test('remainingTimeText shows hours and minutes remaining', () {
      final future = baseTime.add(const Duration(hours: 4, minutes: 15));
      final text = AppDateUtils.remainingTimeText(future, baseTime);
      expect(text, '4 saat 15 dk kaldı');
    });

    test('isDueWithin24Hours returns true when < 24h and not expired', () {
      final within24 = baseTime.add(const Duration(hours: 12));
      final beyond24 = baseTime.add(const Duration(hours: 30));
      final past = baseTime.subtract(const Duration(hours: 1));

      expect(AppDateUtils.isDueWithin24Hours(within24, baseTime), isTrue);
      expect(AppDateUtils.isDueWithin24Hours(beyond24, baseTime), isFalse);
      expect(AppDateUtils.isDueWithin24Hours(past, baseTime), isFalse);
    });
  });
}

