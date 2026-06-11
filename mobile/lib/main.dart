import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rescue_app/screens/rescue_alert_app.dart';
import 'firebase_options.dart';

// Future<void> _startFirebaseTokenSync() async {
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   if (currentUser != null) {
//     await StorageManager.instance.syncFirebaseUser(currentUser);
//     final String? token = await currentUser.getIdToken();
//     if (token != null && token.isNotEmpty) {
//       RestApiService().setAuthToken(token);
//     }
//   }

//   FirebaseAuth.instance.idTokenChanges().listen((user) async {
//     if (user == null) {
//       await StorageManager.instance.logout();
//       RestApiService().clearTokens();
//     } else {
//       await StorageManager.instance.syncFirebaseUser(user);
//       final String? token = await user.getIdToken();
//       if (token != null && token.isNotEmpty) {
//         RestApiService().setAuthToken(token);
//       }
//     }
//   });
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const env = String.fromEnvironment('ENV', defaultValue: 'staging');
  await dotenv.load(fileName: '.env.$env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await _startFirebaseTokenSync();
  runApp(const RescueAlertApp());
}
