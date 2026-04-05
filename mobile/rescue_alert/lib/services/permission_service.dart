import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<void> requestStartupPermissions() async {
    await [
      Permission.notification,
      Permission.locationWhenInUse,
      Permission.microphone,
    ].request();
  }

  Future<bool> hasMicrophone() async => Permission.microphone.isGranted;

  Future<bool> hasLocation() async => Permission.locationWhenInUse.isGranted;
}
