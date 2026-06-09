// =============================================================================
// NADDEFLI — main.dart
// Layer: Flutter Mobile App — ENTRY POINT
// Purpose: Starts the app: initializes Firebase, local storage, then runs NaddefliApp.
// Connects to: Firebase SDK, StorageService, app.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'utils/storage_service.dart';

Future<void> main() async {
  // Step 1: Required before any async plugin (Firebase, SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Connect to Firebase (Google's auth servers) for login on the phone
  await Firebase.initializeApp();

  // Step 3: Open local storage so we can read saved JWT token on next launch
  await StorageService.init();

  // Step 4: Launch the app UI (see app.dart for routes and state)
  runApp(const NaddefliApp());
}
