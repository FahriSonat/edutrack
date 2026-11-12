// ==============================================================================
// 📌 DOSYA: lib/core/demo/demo_data.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Canlı Firebase veritabanı bağlantısı olmadan veya hızlı test ve sunum
//           senaryolarında kullanılan zengin sahte (mock / demo) veri deposu.
// 📋 İÇERİK:
//   - sampleAssignments: Açık, gecikmiş, kapalı ve farklı geç teslim kurallarına sahip ödevler
//   - sampleStudentSubmissions: Öğrenci bazlı detaylı teslim ve dosya ekleri
//   - teacherSampleSubmissions: Eğitmen değerlendirme ekranı için öğrenci teslim listesi
//   - sampleGrades: OBS (Öğrenci Bilgi Sistemi) vize, ödev, final, harf notu kayıtları
//   - sampleSchedule: Haftalık ders ve laboratuvar programı
//   - sampleUsers: Öğrenci, öğretmen ve admin kullanıcı profilleri
//   - sampleClasses: Üniversite bölüm ve sınıf listesi
//   - sampleAnnouncements: Sistem ve ders duyuruları
// ==============================================================================

import '../../features/assignments/domain/entities/assignment.dart';
import '../../features/assignments/domain/entities/late_policy.dart';
import '../../features/submissions/domain/entities/submission.dart';
import '../../features/submissions/domain/entities/submission_file.dart';
import '../../features/users/domain/entities/app_user.dart';

/// Test ve demo gösterimleri için statik veri sağlayıcı sınıf
class DemoData {
  DemoData._();

  /// Göreceli tarih hesaplamaları için referans alınan çalışma anı
  static final now = DateTime.now();

  // ============================================================================
  // 📚 1. ÖRNEK ÖDEVLER (Açık, Geç Teslim, Kapalı)
  // ============================================================================
  static final List<Assignment> sampleAssignments = [
    Assignment(
      id: 'asg_1',
      offeringId: 'offering_ceng301',
      classId: 'bilgisayar_muh_3',
      teacherId: 'demo_teacher_1',
      courseName: 'Mobil Uygulama Geliştirme',
      title: 'Ödev 1: Flutter GitHub API Entegrasyonu',
      description:
          'Dio kütüphanesi kullanarak GitHub REST API üzerinden public repository ve commit bilgilerini listeleyen bir mobil arayüz geliştiriniz. Kodlar Clean Architecture prensiplerine uygun olmalıdır.',
      maxScore: 100,
      createdAt: now.subtract(const Duration(days: 3)),
      dueAt: now.add(const Duration(days: 4, hours: 5)), // Açık (Open)
      requiresRepo: true,
      latePolicy: LatePolicy.allowLate,
      latePenaltyPercent: 15,
      lateUntil: now.add(const Duration(days: 7)),
    ),
    Assignment(
      id: 'asg_2',
      offeringId: 'offering_ceng302',
      classId: 'bilgisayar_muh_3',
      teacherId: 'demo_teacher_1',
      courseName: 'Yazılım Mimarisi ve Tasarım Desenleri',
      title: 'Ödev 2: Repository Pattern ve Riverpod Yönetimi',
      description:
          'Domain, Data ve Presentation katmanlarını ayırarak Result/Failure yapısı ile hata yönetimini sağlayan örnek bir uygulama teslim ediniz.',
      maxScore: 100,
      createdAt: now.subtract(const Duration(days: 8)),
      dueAt: now.subtract(const Duration(hours: 14)), // Süresi Geçti ama Geç Teslim Açık (Late)
      requiresRepo: true,
      latePolicy: LatePolicy.allowLate,
      latePenaltyPercent: 20,
      lateUntil: now.add(const Duration(days: 2)),
    ),
    Assignment(
      id: 'asg_3',
      offeringId: 'offering_ceng303',
      classId: 'bilgisayar_muh_3',
      teacherId: 'demo_teacher_1',
      courseName: 'Veritabanı Yönetim Sistemleri',
      title: 'Ödev 3: Firestore Security Rules ve İndeksleme',
      description:
          'Kullanıcı rollerine ve sunucu zaman damgasına göre kurallar yazarak doküman güvenlik modelini kurgulayınız.',
      maxScore: 100,
      createdAt: now.subtract(const Duration(days: 14)),
      dueAt: now.subtract(const Duration(days: 2)), // Kapalı (Closed)
      requiresRepo: true,
      latePolicy: LatePolicy.closed,
    ),
    Assignment(
      id: 'asg_4',
      offeringId: 'offering_ceng301',
      classId: 'bilgisayar_muh_3',
      teacherId: 'demo_teacher_1',
      courseName: 'Mobil Uygulama Geliştirme',
      title: 'Laboratuvar 1: Material 3 Koyu Mavi Tema Tasarımı',
      description:
          'Proje tasarım rehberinde verilen renk kodları ve tipografi kuralları ile tema konfigürasyonu hazırlayınız.',
      maxScore: 100,
      createdAt: now.subtract(const Duration(days: 20)),
      dueAt: now.subtract(const Duration(days: 10)),
      requiresRepo: true,
      latePolicy: LatePolicy.closed,
    ),
  ];

  // ============================================================================
  // 📥 2. ÖRNEK ÖĞRENCİ TESLİMLERİ (Öğrenci Kendi Ekranında)
  // ============================================================================
  static final Map<String, Submission> sampleStudentSubmissions = {
    'asg_4': Submission(
      studentUid: 'demo_student_1',
      studentName: 'Ahmet Yılmaz',
      submittedAt: now.subtract(const Duration(days: 11)),
      isLate: false,
      repoUrl: 'https://github.com/octocat/edutrack-theme',
      repoOwner: 'octocat',
      repoName: 'edutrack-theme',
      branch: 'main',
      latestCommitSha: '7a9f2bc45129',
      commitCount: 6,
      commitsAfterDeadline: 0,
      firstCommitAt: now.subtract(const Duration(days: 14)),
      lastCommitAt: now.subtract(const Duration(days: 11, hours: 2)),
      note: 'Hocam, tasarım kılavuzuna göre koyu mavi soft renk paleti hazırlandı. Rapor ve ekran görüntüleri ekte mevcuttur.',
      attachedFiles: const [
        SubmissionFile(name: 'Tema_Tasarim_Raporu.pdf', size: 1024 * 340, extension: 'pdf'),
        SubmissionFile(name: 'AnaSayfa_Gorunumu.png', size: 1024 * 610, extension: 'png'),
        SubmissionFile(name: 'Renk_Paleti_Belgesi.docx', size: 1024 * 120, extension: 'docx'),
      ],
      score: 95,
      feedback: 'Tebrikler, renk paleti ve tipografi tam kurallara uygun.',
      gradedAt: now.subtract(const Duration(days: 9)),
    ),
  };

  // ============================================================================
  // 👨‍🏫 3. EĞİTMEN İÇİN ÖDEV TESLİM LİSTESİ (asg_1 Ödevi Teslimleri)
  // ============================================================================
  static final List<Submission> teacherSampleSubmissions = [
    Submission(
      studentUid: 'student_101',
      studentName: 'Ahmet Yılmaz',
      submittedAt: now.subtract(const Duration(hours: 3)),
      isLate: false,
      repoUrl: 'https://github.com/octocat/edutrack-app',
      repoOwner: 'octocat',
      repoName: 'edutrack-app',
      branch: 'main',
      latestCommitSha: '4c8e1a90234b',
      commitCount: 14,
      commitsAfterDeadline: 0,
      firstCommitAt: now.subtract(const Duration(days: 2)),
      lastCommitAt: now.subtract(const Duration(hours: 4)),
      note: 'Hocam Dio servisi ve GitHub Url Parser testleri eklendi. Test raporunu PDF olarak yükledim.',
      attachedFiles: const [
        SubmissionFile(name: 'Birim_Test_Sonuclari.pdf', size: 1024 * 280, extension: 'pdf'),
        SubmissionFile(name: 'Github_Servis_Semasi.jpg', size: 1024 * 450, extension: 'jpg'),
      ],
      score: null, // Henüz notlanmadı
    ),
    Submission(
      studentUid: 'student_102',
      studentName: 'Zeynep Kaya',
      submittedAt: now.subtract(const Duration(hours: 1)),
      isLate: false,
      repoUrl: 'https://github.com/zeynepk/flutter-github',
      repoOwner: 'zeynepk',
      repoName: 'flutter-github',
      branch: 'master',
      latestCommitSha: '9b3f0c112e45',
      commitCount: 9,
      commitsAfterDeadline: 0,
      firstCommitAt: now.subtract(const Duration(days: 1)),
      lastCommitAt: now.subtract(const Duration(hours: 1, minutes: 30)),
      note: 'Hocam ekteki dokümanda commit akışını açıkladım.',
      attachedFiles: const [
        SubmissionFile(name: 'Proje_Aciklamasi.docx', size: 1024 * 190, extension: 'docx'),
      ],
      score: 88,
      feedback: 'Başarılı bir çalışma, UI geliştirmesi yapılabilir.',
      gradedAt: now.subtract(const Duration(minutes: 20)),
    ),
    Submission(
      studentUid: 'student_103',
      studentName: 'Burak Demir',
      submittedAt: now.subtract(const Duration(minutes: 45)),
      isLate: true,
      repoUrl: 'https://github.com/burakd/repo-submission',
      repoOwner: 'burakd',
      repoName: 'repo-submission',
      branch: 'main',
      latestCommitSha: '11ae88fc9021',
      commitCount: 5,
      commitsAfterDeadline: 2,
      note: 'Biraz geciktim hocam, rapor dosyasını ekledim.',
      attachedFiles: const [
        SubmissionFile(name: 'Gecikme_Raporu.pdf', size: 1024 * 160, extension: 'pdf'),
      ],
      score: null,
    ),
  ];

  // ============================================================================
  // 📊 4. OBS NOT LİSTESİ (Vize, Ödev, Final, Ortalama, Harf Notu)
  // ============================================================================
  static final List<Map<String, dynamic>> sampleGrades = [
    {
      'code': 'CENG301',
      'name': 'Mobil Uygulama Geliştirme',
      'midterm': 85,
      'assignment': 95,
      'final': 90,
      'average': 89.5,
      'letter': 'AA',
    },
    {
      'code': 'CENG302',
      'name': 'Yazılım Mimarisi',
      'midterm': 78,
      'assignment': 80,
      'final': 82,
      'average': 80.2,
      'letter': 'BA',
    },
    {
      'code': 'CENG303',
      'name': 'Veritabanı Yönetimi',
      'midterm': 65,
      'assignment': 70,
      'final': 75,
      'average': 71.0,
      'letter': 'BB',
    },
    {
      'code': 'CENG304',
      'name': 'Bilgisayar Ağları',
      'midterm': 92,
      'assignment': 88,
      'final': 94,
      'average': 92.2,
      'letter': 'AA',
    },
  ];

  // ============================================================================
  // 🗓️ 5. HAFTALIK DERS PROGRAMI
  // ============================================================================
  static final List<Map<String, dynamic>> sampleSchedule = [
    {
      'day': 'Pazartesi',
      'time': '09:00 - 11:50',
      'code': 'CENG301',
      'name': 'Mobil Uygulama Geliştirme',
      'room': 'Lab 302',
      'teacher': 'Dr. Ayşe Demir',
    },
    {
      'day': 'Salı',
      'time': '13:00 - 15:50',
      'code': 'CENG302',
      'name': 'Yazılım Mimarisi',
      'room': 'Derslik B-12',
      'teacher': 'Doç. Dr. Serkan Çelik',
    },
    {
      'day': 'Çarşamba',
      'time': '10:00 - 12:50',
      'code': 'CENG303',
      'name': 'Veritabanı Yönetimi',
      'room': 'Lab 201',
      'teacher': 'Prof. Dr. Hakan Erdem',
    },
    {
      'day': 'Perşembe',
      'time': '14:00 - 16:50',
      'code': 'CENG304',
      'name': 'Bilgisayar Ağları',
      'room': 'Derslik A-05',
      'teacher': 'Dr. Murat Şahin',
    },
    {
      'day': 'Cuma',
      'time': '11:00 - 12:50',
      'code': 'ENG301',
      'name': 'Teknik İngilizce',
      'room': 'Derslik C-01',
      'teacher': 'Öğr. Gör. Elif Yıldız',
    },
  ];

  // ============================================================================
  // 👥 6. ÖRNEK KULLANICILAR (Admin Yönetim Ekranı İçin)
  // ============================================================================
  static final List<AppUser> sampleUsers = [
    const AppUser(
      uid: 'user_1',
      fullName: 'Ahmet Yılmaz',
      email: 'ogrenci@edutrack.com',
      role: UserRole.student,
      studentNo: '2024101',
      classId: 'bilgisayar_muh_3',
      githubUsername: 'octocat',
    ),
    const AppUser(
      uid: 'user_2',
      fullName: 'Zeynep Kaya',
      email: 'zeynep@edutrack.com',
      role: UserRole.student,
      studentNo: '2024102',
      classId: 'bilgisayar_muh_3',
      githubUsername: 'zeynepk',
    ),
    const AppUser(
      uid: 'user_3',
      fullName: 'Burak Demir',
      email: 'burak@edutrack.com',
      role: UserRole.student,
      studentNo: '2024103',
      classId: 'bilgisayar_muh_3',
      githubUsername: 'burakd',
    ),
    const AppUser(
      uid: 'user_4',
      fullName: 'Dr. Ayşe Demir',
      email: 'ogretmen@edutrack.com',
      role: UserRole.teacher,
      defaultLatePolicy: 'allowLate',
    ),
    const AppUser(
      uid: 'user_5',
      fullName: 'Doç. Dr. Serkan Çelik',
      email: 'serkan@edutrack.com',
      role: UserRole.teacher,
      defaultLatePolicy: 'closed',
    ),
    const AppUser(
      uid: 'user_6',
      fullName: 'Mehmet Kaya',
      email: 'admin@edutrack.com',
      role: UserRole.admin,
    ),
  ];

  // ============================================================================
  // 🏫 7. ÖRNEK SINIFLAR VE ŞUBELER
  // ============================================================================
  static final List<Map<String, dynamic>> sampleClasses = [
    {'id': 'bilgisayar_muh_1', 'name': 'Bilgisayar Mühendisliği 1. Sınıf', 'gradeLevel': 1, 'studentCount': 45},
    {'id': 'bilgisayar_muh_2', 'name': 'Bilgisayar Mühendisliği 2. Sınıf', 'gradeLevel': 2, 'studentCount': 50},
    {'id': 'bilgisayar_muh_3', 'name': 'Bilgisayar Mühendisliği 3. Sınıf', 'gradeLevel': 3, 'studentCount': 42},
    {'id': 'bilgisayar_muh_4', 'name': 'Bilgisayar Mühendisliği 4. Sınıf', 'gradeLevel': 4, 'studentCount': 38},
  ];

  // ============================================================================
  // 📢 8. ÖRNEK DUYURULAR
  // ============================================================================
  static final List<Map<String, dynamic>> sampleAnnouncements = [
    {
      'title': 'Güz Dönemi Proje Teslim Takvimi Açıklandı',
      'body': 'Tüm bitirme projeleri ve dönem ödevleri için son teslim tarihleri sisteme tanımlanmıştır.',
      'author': 'Mehmet Kaya (Sistem Yöneticisi)',
      'date': now.subtract(const Duration(days: 1)),
    },
    {
      'title': 'Mobil Uygulama Ödev 1 Hakkında Bilgilendirme',
      'body': 'GitHub repo linkinizin public olduğundan ve commit committer date bilgilerinin doğruluğundan emin olunuz. Rapor PDF veya görsel formatında yüklenebilir.',
      'author': 'Dr. Ayşe Demir',
      'date': now.subtract(const Duration(days: 3)),
    },
  ];
}
