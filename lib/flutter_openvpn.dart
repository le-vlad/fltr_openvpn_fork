import 'dart:async';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Track vpn profile status.
typedef OnProfileStatusChanged = Function(bool isProfileLoaded);

/// Track Vpn status.
///
/// Status strings are but not limited to:
/// "CONNECTING", "CONNECTED", "DISCONNECTING", "DISCONNECTED", "INVALID", "REASSERING", "AUTH", ...
/// print status to get full insight.
/// status might change depending on platform.
typedef OnVPNStatusChanged = Function(String status);

const String _profileLoaded = "profileloaded";
const String _profileLoadFailed = "profileloadfailed";

class FlutterOpenvpn {
  static const MethodChannel _channel = const MethodChannel('flutter_openvpn');
  static OnProfileStatusChanged _onProfileStatusChanged;
  static OnVPNStatusChanged _onVPNStatusChanged;

  /// Initialize plugin.
  ///
  /// Must be called before any use.
  ///
  /// localizedDescription and providerBundleIdentifier is only required on iOS.
  ///
  /// localizedDescription : Name of vpn profile in settings.
  ///
  /// providerBundleIdentifier : Bundle id of your vpn extension.
  ///
  /// returns {"currentStatus" : "VPN_CURRENT_STATUS",
  ///
  /// "expireAt" : "VPN_EXPIRE_DATE_STRING_IN_FORMAT(yyyy-MM-dd HH:mm:ss)",} if successful
  ///
  ///  returns null if failed
  static Future<dynamic> init(
      {String providerBundleIdentifier, String localizedDescription}) async {
    dynamic isInited = await _channel.invokeMethod("init", {
      'localizedDescription': localizedDescription,
      'providerBundleIdentifier': providerBundleIdentifier,
    }).catchError((error) => error);
    if (!(isInited is PlatformException) || isInited == null) {
      _channel.setMethodCallHandler((call) {
        switch (call.method) {
          case _profileLoaded:
            _onProfileStatusChanged?.call(true);
            break;
          case _profileLoadFailed:
            _onProfileStatusChanged?.call(false);
            break;
          default:
            _onVPNStatusChanged?.call(call.method);
        }
        return null;
      });
      return isInited;
    } else {
      print('OpenVPN Initilization failed');
      print((isInited as PlatformException).message);
      print((isInited as PlatformException).details);
      return null;
    }
  }

  /// Load profile and start connecting.
  ///
  /// if expireAt is provided
  /// Vpn session stops itself at given date.
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

  /// stops any connected session.
  static Future<void> stopVPN() async {
    await _channel.invokeMethod("stop");
  }
}
