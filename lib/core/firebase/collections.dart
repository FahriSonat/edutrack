// ==============================================================================
// 📌 DOSYA: lib/core/firebase/collections.dart
// 📌 AÇIKLAMA: Cloud Firestore veritabanındaki koleksiyon (collection) ve
//              alt koleksiyon (subcollection) isimlerinin merkezi sabitleri.
// ==============================================================================

/// [Collections], Firestore koleksiyon adlarını tek bir noktada toplayarak
/// yazım hatalarını önler ve refaktör kolaylığı sağlar.
class Collections {
  Collections._();

  /// Kullanıcı profilleri koleksiyonu (`/users/{uid}`)
  static const String users = 'users';

  /// Sınıf / Şube tanımları (`/classes/{id}`)
  static const String classes = 'classes';

  /// Ders tanımları (`/courses/{id}`)
  static const String courses = 'courses';

  /// Açılan ders dönemleri ve atamaları (`/offerings/{id}`)
  static const String offerings = 'offerings';

  /// Ders programı zaman dilimleri alt koleksiyonu (`/offerings/{id}/slots/{slotId}`)
  static const String slots = 'slots';

  /// Ödevler koleksiyonu (`/assignments/{id}`)
  static const String assignments = 'assignments';

  /// Ödev teslimleri alt koleksiyonu (`/assignments/{id}/submissions/{studentUid}`)
  static const String submissions = 'submissions';

  /// Sınav tanımları (`/exams/{id}`)
  static const String exams = 'exams';

  /// Sınav notları alt koleksiyonu (`/exams/{id}/grades/{studentUid}`)
  static const String grades = 'grades';

  /// Yoklama oturumları (`/attendance/{docId}`)
  static const String attendance = 'attendance';

  /// Yoklama kayıtları alt koleksiyonu (`/attendance/{docId}/records/{studentUid}`)
  static const String records = 'records';

  /// Duyurular koleksiyonu (`/announcements/{id}`)
  static const String announcements = 'announcements';
}
