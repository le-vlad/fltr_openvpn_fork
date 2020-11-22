import Flutter
import UIKit
import NetworkExtension

public class SwiftFlutterOpenvpnPlugin: NSObject, FlutterPlugin {
    private static var utils : VPNUtils!;
    private static var channel : FlutterMethodChannel!;
  public static func register(with registrar: FlutterPluginRegistrar) {
     channel = FlutterMethodChannel(name: "flutter_openvpn", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterOpenvpnPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "platformVersion"{
    result("iOS " + UIDevice.current.systemVersion)
    }
    do{
    if call.method == "init"{
        let providerBundleIdentifier: String? = (call.arguments as? [String: Any])?["providerBundleIdentifier"] as? String
        let localizedDescription: String? = (call.arguments as? [String: Any])?["localizedDescription"] as? String
        if providerBundleIdentifier == nil  {
            result(FlutterError(code: "-2", message: "providerBundleIdentifier content empty or null", details: nil));
            return;
        }
        if localizedDescription == nil  {
            result(FlutterError(code: "-3", message: "localizedDescription content empty or null", details: nil));
            return;
        }
        SwiftFlutterOpenvpnPlugin.utils = VPNUtils();
        SwiftFlutterOpenvpnPlugin.utils.localizedDescription = localizedDescription;
        SwiftFlutterOpenvpnPlugin.utils.providerBundleIdentifier = providerBundleIdentifier;
        SwiftFlutterOpenvpnPlugin.utils.channel = SwiftFlutterOpenvpnPlugin.channel
         SwiftFlutterOpenvpnPlugin.utils.loadProviderManager { (err : Error?) in
            if err == nil {
                var args =  [String: Any]()
                args["expireAt"] = SwiftFlutterOpenvpnPlugin.utils.currentExpireAt();
                args["currentStatus"] = SwiftFlutterOpenvpnPlugin.utils.currentStatus();
                result(args)
            }else {
                result(FlutterError(code: "-4", message: err.debugDescription, details: err?.localizedDescription));
            }
        }
    }
        if call.method == "lunch" {
            let ovpn: String? = (call.arguments as? [String: Any])?["ovpnFileContent"] as? String
            let expireAt: String? = (call.arguments as? [String: Any])?["expireAt"] as? String
            let user: String? = (call.arguments as? [String: Any])?["user"] as? String
            let pass: String? = (call.arguments as? [String: Any])?["pass"] as? String
            if ovpn == nil {
                result(FlutterError(code: "-1", message: "ovpn content empty or null", details: nil));
                return;
            }
            
            SwiftFlutterOpenvpnPlugin.utils.configureVPN(ovpnFileContent: ovpn, expireAt: expireAt, user: user, pass : pass,completion: { (success : Error?) -> Void in

                
                if success == nil {
                   result(nil)
                } else {
                    result(FlutterError(code: "-5", message: success?.localizedDescription, details: success.debugDescription))
                }
            });
                
            
            
        }
        if call.method == "stop" {
            SwiftFlutterOpenvpnPlugin.utils.stopVPN();
            result(nil)
        }
    }catch let exception {
        result(FlutterError(code: "-2", message: "Unknown error", details: exception.localizedDescription));
    }
  }
}
