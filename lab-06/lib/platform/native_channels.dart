import 'package:flutter/services.dart';

class BatteryInfo {
  const BatteryInfo({
    required this.level,
    required this.platform,
    required this.api,
  });

  final int level;
  final String platform;
  final String api;
}

class NativeChannels {
  NativeChannels._();

  static const _sensors = MethodChannel('lab06/sensors');
  static const _battery = MethodChannel('lab06/battery');
  static const _apps = MethodChannel('lab06/apps');

  static Future<double> lightLevel() async {
    final value = await _sensors
        .invokeMethod<double>('getLightLevel')
        .timeout(const Duration(seconds: 3));
    return value ?? 0;
  }

  static Future<BatteryInfo> batteryInfo() async {
    final map = await _battery.invokeMapMethod<String, dynamic>('getBatteryLevel');
    return BatteryInfo(
      level: map?['level'] as int? ?? -1,
      platform: map?['platform'] as String? ?? '',
      api: map?['api'] as String? ?? '',
    );
  }

  static Future<bool> openMail(String subject) async {
    final opened = await _apps.invokeMethod<bool>('openMail', {'subject': subject});
    return opened ?? false;
  }
}
