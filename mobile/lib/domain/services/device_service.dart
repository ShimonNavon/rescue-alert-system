import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  final _plugin = DeviceInfoPlugin();

  Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      return (await _plugin.androidInfo).id;
    } else if (Platform.isIOS) {
      return (await _plugin.iosInfo).identifierForVendor ?? 'unknown';
    }
    return 'unknown';
  }

  String getPlatform() => Platform.operatingSystem;

  Future<String> getDeviceModel() async {
    if (Platform.isAndroid) {
      final info = await _plugin.androidInfo;
      return '${info.manufacturer} ${info.model}';
    } else if (Platform.isIOS) {
      return (await _plugin.iosInfo).model;
    }
    return 'unknown';
  }
}
