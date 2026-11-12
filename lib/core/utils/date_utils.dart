// ==============================================================================
// 📌 DOSYA: lib/core/utils/date_utils.dart
// 📌 AÇIKLAMA: Tarih ve saat biçimlendirme, son teslim kalan süre hesaplama ve
//              son 24 saat aciliyet kontrolü yardımcı sınıfı.
// ==============================================================================

import 'package:intl/intl.dart';

/// [AppDateUtils], UI katmanında tarihlerin yerelleştirilmiş (dd.MM.yyyy)
/// ve anlaşılır (örn: "2 gün 4 saat kaldı") biçimde gösterilmesini sağlar.
class AppDateUtils {
  AppDateUtils._();

  // --- Biçimlendirici Sabitler ---
  static final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');
  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// Tarih ve saati '24.11.2024 17:30' şeklinde döner
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _dateTimeFormat.format(dateTime.toLocal());
  }

  /// Sadece tarihi '24.11.2024' şeklinde döner
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _dateFormat.format(dateTime.toLocal());
  }

  /// Sadece saati '17:30' şeklinde döner
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _timeFormat.format(dateTime.toLocal());
  }

  /// Son teslim tarihine ne kadar süre kaldığını insan dostu Türkçe metin olarak hesaplar.
  /// Test edilebilirliği artırmak için opsiyonel [now] parametresi alır.
  static String remainingTimeText(DateTime deadline, [DateTime? now]) {
    final current = now ?? DateTime.now();
    final diff = deadline.difference(current);

    if (diff.isNegative) {
      return 'Süre doldu';
    }

    if (diff.inDays > 0) {
      final days = diff.inDays;
      final hours = diff.inHours % 24;
      if (hours > 0) {
        return '$days gün $hours saat kaldı';
      }
      return '$days gün kaldı';
    }

    if (diff.inHours > 0) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (minutes > 0) {
        return '$hours saat $minutes dk kaldı';
      }
      return '$hours saat kaldı';
    }

    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} dakika kaldı';
    }

    return 'Son dakikalar';
  }

  /// Ödevin teslimine 24 saatten az kalıp kalmadığını kontrol eder (Aciliyet rozeti için).
  static bool isDueWithin24Hours(DateTime deadline, [DateTime? now]) {
    final current = now ?? DateTime.now();
    final diff = deadline.difference(current);
    return !diff.isNegative && diff.inHours < 24;
  }
}
