// ==============================================================================
// 📌 DOSYA: lib/features/assignments/domain/entities/late_policy.dart
// 📌 AÇIKLAMA: Ödev geç teslim politikası (`LatePolicy`) ve anlık teslim durumu
//              (`SubmissionState`) enum tanımları ve string dönüşüm yardımcıları.
// ==============================================================================

/// Geç teslim kabul politikası
enum LatePolicy {
  /// Son teslim tarihi geçtiğinde teslimler kesin olarak kapatılır
  closed,

  /// Son teslim tarihi geçse de gecikme damgasıyla teslim kabul edilir
  allowLate;

  static LatePolicy fromString(String? policy) {
    return switch (policy?.toLowerCase()) {
      'allowlate' => LatePolicy.allowLate,
      _ => LatePolicy.closed,
    };
  }

  String get asString => switch (this) {
        LatePolicy.closed => 'closed',
        LatePolicy.allowLate => 'allowLate',
      };

  String get displayName => switch (this) {
        LatePolicy.closed => 'Geç Teslime Kapalı',
        LatePolicy.allowLate => 'Geç Teslime İzin Ver',
      };
}

/// Ödevin teslim anındaki aktif durumu
enum SubmissionState {
  /// Zamanında teslim penceresi açık (dueAt öncesi)
  open,

  /// Son teslim geçmiş ancak allowLate politikasıyla gecikmeli teslime izin veriliyor
  late,

  /// Teslim süresi tamamen dolmuş ve kilitlenmiş
  closed;

  String get displayName => switch (this) {
        SubmissionState.open => 'Teslime Açık',
        SubmissionState.late => 'Geç Teslim Kabul Ediliyor',
        SubmissionState.closed => 'Teslime Kapalı',
      };
}


