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

  /// Origin of the backend, without the `/api` prefix.
  ///
  /// Every request path in RestApiService already starts with `/api/`, and Dio
  /// joins baseUrl and path by plain concatenation. An `API_BASE_URL` ending in
  /// `/api` therefore produced `https://host/api/api/...`, which the backend
  /// answers with 404 -- so any trailing `/api` is trimmed here rather than in
  /// the .env files, which are gitignored and differ per machine.
  static String get apiBaseUrl {
    var base = (dotenv.env['API_BASE_URL'] ?? _defaultApiBaseUrl).trim();
    base = base.replaceFirst(RegExp(r'/+$'), '');
    base = base.replaceFirst(RegExp(r'/api$'), '');
    return base.replaceFirst(RegExp(r'/+$'), '');
  }

  static const String _defaultApiBaseUrl =
      'https://rescue-alert-system-malachim-badrachim.navonsimon.com';

  static bool get isProduction => env == 'production';
  static bool get isStaging => env == 'staging';
}
