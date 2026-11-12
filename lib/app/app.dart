// ==============================================================================
// 📌 DOSYA: lib/app/app.dart
// 📌 AÇIKLAMA: EduTrack uygulamasının en üst seviye MaterialApp yapılandırması.
//              Material 3 temasını (Koyu Gece Mavisi), GoRouter yönlendiricisini
//              ve genel başlık ayarlarını belirler.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// [EduTrackApp], Riverpod [ConsumerWidget] yapısını kullanarak GoRouter yapılandırmasını
/// dinler ve Material 3 temasıyla kullanıcıya sunar.
class EduTrackApp extends ConsumerWidget {
  const EduTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- 1. Router Yapılandırmasını Dinleme ---
    final router = ref.watch(appRouterProvider);

    // --- 2. MaterialApp.router İnşası ---
    return MaterialApp.router(
      title: 'EduTrack',
      debugShowCheckedModeBanner: false,
      // Koyu tema varsayılan ve zorunlu temadır
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      // GoRouter yapılandırması
      routerConfig: router,
    );
  }
}
