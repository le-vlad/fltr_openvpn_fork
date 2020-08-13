# flutter_openvpn

A new Flutter plugin that uses OpenVpn.

# Installation

1. Depend on it
Add this to your package's pubspec.yaml file:

```dart
dependencies:
  flutter_openvpn: ^0.1.0

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
1. Open app level build.gradle file (android/app/build.gradle)
2. In android->defaultConfig scope change this line
```dart
defaultConfig {
        .
        .
        .
        minSdkVersion 22 //default is 16
        .
        .
        .
    }
```
### iOS integration
- Add [OpenVPNAdapter](https://github.com/ss-abramchuk/OpenVPNAdapter) dependency to PodFile
1. Open ios/PodFile
2. Change your PodFile according to this:
```dart
	.
	.
	.
pod 'Flutter', :path => 'Flutter'
pod 'OpenVPNAdapter', :git => 'https://github.com/ss-abramchuk/OpenVPNAdapter.git', :tag => '0.6.0' //add this line
	.
	.
	.
```
3. Run 'pod install' command in /ios directory
- Add VPN Entitlements
1. Open ios/Runner.xcworkspace in xcode
2. In Runner target -> Signing & Capabalities -> Click on "+ Capabality" button
3. Add both "Network Extension" and "App Groups" capabalities
4. Select ONLY "Packet Tunnel" form newly created Network Extension menu.
5. Make sure your Bundle identifier is checked in App Groups.
View [This Screenshot]() for visual Guide
- Add Network Extension Target
1. Below Runner target click on "+" button to add new target
2. Search for "Network Extension" in newly opened page and click on next
3. Give it a name(Without space) and make sure to select Swift as Language and Packet Tunnel as Provider Type.
4. Click on finish and agree to any message relating to "Activating Extension"
5. Repeat "Add VPN Entitlements" for newly created target as well
View [This Screenshot]() for visual Guide
- Change minimum platform target to iOS 9.0 :
1. In Runner target -> Deployment Info -> change Target to iOS 9.0
2. Repeat step 2 for your VPN Extension Target as well
- Add OpenVPNAdpter dependency to VPNExtension Target
1. Click on your VPNExtension Target
2. Select General tab
3. In Frameworks and Libraries section click on + button
4. Search for "OpenVPNAdapter.framework" and click on Add
5. Select "Do Not Embed" in OpenVPNAdapter.framework Embed Options
View [This Screenshot]() for visual Guide
- Disable Bitcode
1. In Vpn Extension Target -> Build Settings
2. Search for "Bitcode" and set it to NO
- Add code to PacketTunnelProvider
1. Open VPNExtension folder/PacketTunnelProvider.swift in xcode.
2. Replace all code with [this]() and save
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
View [this]() for more info on VPN status Strings
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
. view this [issue]() to stay updated on the matter  
### iOS
. View [Apple Guidelines](https://developer.apple.com/app-store/review/guidelines/#vpn-apps) Relating to VPN
. This plugin DOES use Encryption BUT, It uses Exempt Encryptions 