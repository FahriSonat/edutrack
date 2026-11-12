// ==============================================================================
// 📌 DOSYA: lib/features/users/domain/entities/app_user.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Sistemdeki kullanıcıların (Yönetici, Eğitmen, Öğrenci) kimlik, yetki ve
//           profil bilgilerini temsil eden ana domain varlığı.
// 📋 İÇERİK:
//   - UserRole: admin, teacher, student rol tipleri ve string eşleştirme
//   - AppUser: Kullanıcı temel bilgileri, okul numarası, sınıf kodu, github kullanıcı adı
//   - Helper getters: isAdmin, isTeacher, isStudent yetki kontrolleri
//   - fromMap, toMap ve kopyalama (copyWith) fonksiyonları
// ==============================================================================

/// Sistem içindeki kullanıcı rollerini belirten numaralandırma (Enum).
enum UserRole {
  /// Sistem yöneticisi: Kullanıcı oluşturma, sınıf ve ders atama, log takibi
  admin,

  /// Eğitmen (Öğretim Görevlisi): Ödev oluşturma, repo analizi, notlandırma
  teacher,

  /// Öğrenci: Ödev görüntüleme, GitHub reposu bağlama, teslim gönderme
  student;

  /// Firestore metin değerinden güvenli enum dönüşümü
  static UserRole fromString(String? role) {
    return switch (role?.toLowerCase()) {
      'admin' => UserRole.admin,
      'teacher' => UserRole.teacher,
      'student' => UserRole.student,
      _ => UserRole.student,
    };
  }

  /// Enum adını küçük harfli string olarak verir
  String get asString => name;
}

/// EduTrack sistemindeki her bir kayıtlı kullanıcı profilini temsil eden model.
class AppUser {
  /// Firebase Authentication UID anahtarı
  final String uid;

  /// Ad ve Soyad
  final String fullName;

  /// E-posta adresi
  final String email;

  /// Kullanıcının sistemdeki rolü (admin, teacher, student)
  final UserRole role;

  /// Öğrenciler için OBS okul numarası (örn: 20210108023)
  final String? studentNo;

  /// Öğrencinin kayıtlı olduğu sınıf/şube kimliği (örn: bilgisayar_muh_3)
  final String? classId;

  /// Öğrencinin GitHub kullanıcı adı (örn: octocat)
  final String? githubUsername;

  /// Öğretmenin varsayılan ödev geç teslim politikası tercihi ('closed' | 'allowLate')
  final String? defaultLatePolicy;

  /// Profilin oluşturulduğu tarih
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.studentNo,
    this.classId,
    this.githubUsername,
    this.defaultLatePolicy,
    this.createdAt,
  });

  /// Kullanıcının Admin yetkisinde olup olmadığını denetler
  bool get isAdmin => role == UserRole.admin;

  /// Kullanıcının Eğitmen (Teacher) olup olmadığını denetler
  bool get isTeacher => role == UserRole.teacher;

  /// Kullanıcının Öğrenci (Student) olup olmadığını denetler
  bool get isStudent => role == UserRole.student;

  /// Firestore Map verisinden [AppUser] nesnesi üretir
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      studentNo: map['studentNo'] as String?,
      classId: map['classId'] as String?,
      githubUsername: map['githubUsername'] as String?,
      defaultLatePolicy: map['defaultLatePolicy'] as String?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate() as DateTime?
          : null,
    );
  }

  /// Firestore veritabanına yazılacak Map formatına dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role.asString,
      'studentNo': studentNo,
      'classId': classId,
      'githubUsername': githubUsername,
      'defaultLatePolicy': defaultLatePolicy,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  /// Mevcut nesnenin belirli alanlarını güncelleyerek yeni bir kopyasını oluşturur
  AppUser copyWith({
    String? fullName,
    String? email,
    UserRole? role,
    String? studentNo,
    String? classId,
    String? githubUsername,
    String? defaultLatePolicy,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      studentNo: studentNo ?? this.studentNo,
      classId: classId ?? this.classId,
      githubUsername: githubUsername ?? this.githubUsername,
      defaultLatePolicy: defaultLatePolicy ?? this.defaultLatePolicy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
