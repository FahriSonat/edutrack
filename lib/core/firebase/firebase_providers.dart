// ==============================================================================
// 📌 DOSYA: lib/core/firebase/firebase_providers.dart
// 📌 AÇIKLAMA: Firebase Auth ve Cloud Firestore örneklerini dependency injection (DI)
//              ile Riverpod üzerinden sağlayan merkezi provider tanımları.
// ==============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [FirebaseAuth] singleton örneğini sunan Riverpod provider'ı.
/// Testlerde mock veya fake nesnelerle kolayca ezilebilir (override).
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// [FirebaseFirestore] singleton örneğini sunan Riverpod provider'ı.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
