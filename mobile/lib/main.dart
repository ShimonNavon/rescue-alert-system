import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rescue_app/domain/services/auth_service.dart';
import 'package:rescue_app/screens/rescue_alert_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const env = String.fromEnvironment('ENV', defaultValue: 'staging');
  await dotenv.load(fileName: '.env.$env');
  unawaited(AuthService.instance.restore());
  runApp(const RescueAlertApp());
}
