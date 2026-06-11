import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central access point for all environment variables.
///
/// Values are loaded from .env.staging or .env.production via flutter_dotenv.
/// Run with --dart-define=ENV=production to load the production env file.
class AppEnv {
  const AppEnv._();

  static String get mapboxAccessToken =>
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  static String get env => dotenv.env['ENV'] ?? 'staging';

  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'https://rescue-team.netlify.app';
  }

  static bool get isProduction => env == 'production';
  static bool get isStaging => env == 'staging';
}
