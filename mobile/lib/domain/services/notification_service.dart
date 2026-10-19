import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'auth_service.dart';
import 'deeplink_service.dart';
import 'device_service.dart';

/// Push delivery is intentionally disabled until the FCM replacement (ntfy)
/// is deployed. Authentication and the rest of the app no longer depend on
/// Firebase.
class NotificationService {
  NotificationService({
    required AuthService authService,
    required DeepLinkService deepLinkService,
    required RestApiService apiClient,
    required DeviceService deviceService,
  });

  Future<void> initialize() async {}

  Future<void> registerCurrentToken() async {}

  Future<void> dispose() async {}
}
