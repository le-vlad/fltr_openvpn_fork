import 'dart:async';

import 'package:flutter/services.dart';

class FlutterOpenvpn {
  static const MethodChannel _channel =
      const MethodChannel('flutter_openvpn');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
