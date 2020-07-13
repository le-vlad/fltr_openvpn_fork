import 'dart:async';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

typedef OnProfileStatusChanged = Function(bool isProfileLoaded);
typedef OnVPNStatusChanged = Function(bool vpnActivated);

const String _profileLoaded = "profileloaded";
const String _profileLoadFailed = "profileloadfailed";
const String _vpnActivated = "vpnactivated";
const String _vpnDisabled = "vpndisabled";

class FlutterOpenvpn {
  static const MethodChannel _channel = const MethodChannel('flutter_openvpn');
  static OnProfileStatusChanged _onProfileStatusChanged;
  static OnVPNStatusChanged _onVPNStatusChanged;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> init() async {
    dynamic isInited =
        await _channel.invokeMethod("init").catchError((error) => error);
    if (isInited == null) {
      _channel.setMethodCallHandler((call) {
        switch (call.method) {
          case _profileLoaded:
            _onProfileStatusChanged?.call(true);
            break;
          case _profileLoadFailed:
            _onProfileStatusChanged?.call(false);
            break;
          case _vpnActivated:
            _onVPNStatusChanged?.call(true);
            break;
          case _vpnDisabled:
            _onVPNStatusChanged?.call(true);
            break;
          default:
        }
        return null;
      });
      return true;
    } else {
      print((isInited as PlatformException).message);
      return false;
    }
  }

  static Future<int> lunchVpn(
      String ovpnFileContents,
      OnProfileStatusChanged onProfileStatusChanged,
      OnVPNStatusChanged onVPNStatusChanged,
      {DateTime expireAt}) async {
    _onProfileStatusChanged = onProfileStatusChanged;
    _onVPNStatusChanged = onVPNStatusChanged;
    dynamic isLunched = await _channel.invokeMethod(
      "lunch",
      {
        'ovpnFileContent': ovpnFileContents,
        'expireAt': expireAt == null
            ? null
            : DateFormat("yyyy-MM-dd HH:mm:ss").format(expireAt),
      },
    ).catchError((error) => error);
    if (isLunched == null) return 0;
    print((isLunched as PlatformException).message);
    return int.tryParse((isLunched as PlatformException).code);
  }

  static Future<void> stopVPN() async {
    await _channel.invokeMethod("stop");
  }
}
