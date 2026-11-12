// ==============================================================================
// 📌 DOSYA: lib/firebase_options.dart
// ------------------------------------------------------------------------------
// 🎯 AMAÇ: Firebase servislerinin (Auth, Firestore) projeye bağlanması için
//           gerekli platform bazlı konfigürasyon ve anahtarları sağlar.
// 📋 İÇERİK:
//   - DefaultFirebaseOptions: Android ve diğer platformlar için FirebaseOptions nesnesi
//   - Geliştirme ve test ortamı için hazır placeholder yapılandırması
// ==============================================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Firebase başlatma konfigürasyonunu sağlayan yardımcı sınıf
class DefaultFirebaseOptions {
  /// Çalışma anındaki aktif platforma uygun [FirebaseOptions] nesnesini döner
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  /// Android platformu için Firebase kimlik bilgileri
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderEduTrackKey',
    appId: '1:1234567890:android:edutrackplaceholder',
    messagingSenderId: '1234567890',
    projectId: 'edutrack-app',
    storageBucket: 'edutrack-app.appspot.com',
  );
}
