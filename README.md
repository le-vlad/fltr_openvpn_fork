# flutter_openvpn

A new Flutter plugin that uses OpenVpn.

# Installation

1. Depend on it
   Add this to your package's pubspec.yaml file:

```dart
dependencies:
  flutter_openvpn: ^0.2.0

```

2. Install it
   You can install packages from the command line:

with Flutter:

```dart
$ flutter pub get
```

Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more.

3. Import it
   Now in your Dart code, you can use:

```dart
import 'package:flutter_openvpn/flutter_openvpn.dart';
```

### Supported Platforms

- `22` >= Android
- `9.0` >= iOS

### Build project first

- After adding package to pubspec.yaml, Run build command

```dart
flutter build apk --debug //for android
flutter build ios --no-codesign //for ios
```

Ignore any build errors.

### Android integration

- Change minimum sdk to 22 :

1. Open Your project in Android Studio.
2. Open your MainActivity.java(or .kt for kotlin) file
   (Located in android/app/src/main/YOUR_PACKAGE_NAME/MainActivity)
3. Override onActivityResult in your activity and add this code to function body

```dart
if (requestCode == 1) {
    if (resultCode == RESULT_OK) {
        FlutterOpenvpnPlugin.setPermission(true);
    } else {
        FlutterOpenvpnPlugin.setPermission(false);
    }
}
```

4. Finally import FlutterOpenVpn with this import statement

```dart
import com.topfreelancerdeveloper.flutter_openvpn.FlutterOpenvpnPlugin;
```

### iOS integration

- Add VPN Entitlements

1. Open ios/Runner.xcworkspace in xcode
2. In Runner target -> Signing & Capabalities -> Click on "+ Capabality" button
3. Add both "Network Extension" and "App Groups" capabalities
4. Select ONLY "Packet Tunnel" form newly created Network Extension menu.
5. Make sure your Bundle identifier is checked in App Groups.
6. View [This Screenshot](https://gitlab.com/topfreelancerdeveloper/flutter_openvpn/-/blob/master/screenshots/add_runner_entitlements.png) for visual Guide

- Add Network Extension Target

1. Below Runner target click on "+" button to add new target
2. Search for "Network Extension" in newly opened page and click on next
3. Give it a name(Without space) and make sure to select Swift as Language and Packet Tunnel as Provider Type.
4. Click on finish and agree to any message relating to "Activating Extension"
5. Repeat "Add VPN Entitlements" for newly created target as well
6. View [This Screenshot](https://gitlab.com/topfreelancerdeveloper/flutter_openvpn/-/blob/master/screenshots/add_vpn_extension.png) for visual Guide

- Change minimum platform target to iOS 9.0 :

1. In Runner target -> Deployment Info -> change Target to iOS 9.0
2. Repeat step 2 for your VPN Extension Target as well

- Add [OpenVPNAdapter](https://github.com/ss-abramchuk/OpenVPNAdapter) dependency to PodFile

1. Open ios/PodFile
2. Change your PodFile according to this:

```dart
	.
	.
	.
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

//Add this part
target 'YOUR_TARGET_EXTENSION_NAME' do
  use_frameworks!
  use_modular_headers!
  pod 'OpenVPNAdapter', :git => 'https://github.com/ss-abramchuk/OpenVPNAdapter.git', :tag => '0.7.0'
end
	.
	.
	.
```

3. Run 'pod install' command in /ios directory

- Disable Bitcode

1. In Vpn Extension Target -> Build Settings
2. Search for "Bitcode" and set it to NO

- Add code to PacketTunnelProvider

1. Open VPNExtension folder/PacketTunnelProvider.swift in xcode.
2. Replace all code with [this](https://gitlab.com/topfreelancerdeveloper/flutter_openvpn/-/blob/master/example/ios/RunnerExtension/PacketTunnelProvider.swift) and save

### Dart/Flutter integration

- Initilize plugin

```dart
FlutterOpenvpn.init(
          localizedDescription: "ExampleVPN", //this is required only on iOS
          providerBundleIdentifier: "com.topfreelancerdeveloper.flutterOpenvpnExample.RunnerExtension",//this is required only on iOS
	  //localizedDescription is the name of your VPN profile
	  //providerBundleIdentifier is the bundle id of your vpn extension
)
/* returns {"currentStatus" : "VPN_CURRENT_STATUS",
	   "expireAt" : "VPN_EXPIRE_DATE_STRING_IN_FORMAT(yyyy-MM-dd HH:mm:ss)",} if successful
 returns null if failed
*/
```

View [this](https://gitlab.com/topfreelancerdeveloper/flutter_openvpn/-/blob/master/ios/Classes/VPNUtils.swift) for more info on VPN status Strings

- Add VPN Profile and connect

```dart
FlutterOpenvpn.lunchVpn(
          ovpnFileContent, //content of your .ovpn file
          (isProfileLoaded) => print('isProfileLoaded : $isProfileLoaded'),
          (newVpnStatus) => print('vpnActivated : $newVpnStatus'),
          expireAt: DateTime.now().add(Duration(seconds: 30)),
	  //(Optional) VPN automatically disconnects in next 30 seconds
         )
```

## Publishing to Play Store and App Store

### Android

. Recently I discovered an issue with plugin not working with appbundles
. If you want to publish to play store use apks
. view this [issue](https://gitlab.com/topfreelancerdeveloper/flutter_openvpn/-/issues/1) to stay updated on the matter

### iOS

. View [Apple Guidelines](https://developer.apple.com/app-store/review/guidelines/#vpn-apps) Relating to VPN
. This plugin DOES use Encryption BUT, It uses Exempt Encryptions
