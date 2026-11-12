// ==============================================================================
// 📌 DOSYA: lib/main.dart
// 📌 AÇIKLAMA: EduTrack mobil uygulamasının giriş noktası (Entry Point).
//              Flutter widget ağacını başlatır, Firebase servislerini ayağa kaldırır
//              ve Riverpod state konteynerını (ProviderScope) kurarak kök widget'ı çalıştırır.
// ==============================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'firebase_options.dart';

/// Uygulamanın ana yürütme fonksiyonu.
/// 1. Flutter Engine - Framework bağlantısını sağlar.
/// 2. Firebase bağlantısını başlatır (hata durumunda güvenli loglama yapar).
/// 3. Tüm uygulamayı [ProviderScope] ile sararak Riverpod durum yönetimini aktif eder.
Future<void> main() async {
  // --- 1. Flutter Widget Bağlantısı ---
  WidgetsFlutterBinding.ensureInitialized();

  // --- 2. Firebase Çekirdek Servis Başlatma ---
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase yapılandırması henüz tamamlanmamış ortamlarda (test/demo) uygulamanın çökmesini önler.
    debugPrint('Firebase init warning (production requires flutterfire configure): $e');
  }

  // --- 3. Kök Uygulamayı Başlatma ---
  runApp(const ProviderScope(child: EduTrackApp()));
}
