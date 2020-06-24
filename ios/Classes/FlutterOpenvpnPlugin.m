#import "FlutterOpenvpnPlugin.h"
#if __has_include(<flutter_openvpn/flutter_openvpn-Swift.h>)
#import <flutter_openvpn/flutter_openvpn-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_openvpn-Swift.h"
#endif

@implementation FlutterOpenvpnPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterOpenvpnPlugin registerWithRegistrar:registrar];
}
@end
