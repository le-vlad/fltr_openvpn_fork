//
//  VPNUtils.swift
//  flutter_openvpn
//
//  Created by A A9906 on 7/8/20.
//
import NetworkExtension

@available(iOS 9.0, *)
class VPNUtils {
    var providerManager: NETunnelProviderManager!
    var providerBundleIdentifier : String?
    var localizedDescription : String?
    var channel : FlutterMethodChannel!
    
    

    func loadProviderManager(completion:@escaping (_ error : Error?) -> Void)  {
        
            NETunnelProviderManager.loadAllFromPreferences { (managers, error)  in
                if error == nil {
                    self.providerManager = managers?.first ?? NETunnelProviderManager()
                    
                    completion(nil)
                } else {
                    completion(error)
                }
            }
        
    }
    
    func onVpnStatusChanged(notification : NEVPNStatus) {
        switch notification {
        case NEVPNStatus.connected:
            channel.invokeMethod("CONNECTED" , arguments: nil);
            break;
            case NEVPNStatus.connecting:
            channel.invokeMethod("CONNECTING" , arguments: nil);
            break;
            case NEVPNStatus.disconnected:
            channel.invokeMethod("DISCONNECTED", arguments: nil);
            break;
            case NEVPNStatus.disconnecting:
            channel.invokeMethod("DISCONNECTING", arguments: nil);
            break;
            case NEVPNStatus.invalid:
            channel.invokeMethod("INVALID", arguments: nil);
            break;
            case NEVPNStatus.reasserting:
            channel.invokeMethod("REASSERTING", arguments: nil);
            break;
        default:
            channel.invokeMethod("NULL", arguments: nil);
            break;
        }
    }
    func onVpnStatusChangedString(notification : NEVPNStatus) -> String?{
        switch notification {
        case NEVPNStatus.connected:
                return "CONNECTED";
            
            case NEVPNStatus.connecting:
                return "CONNECTING";
            
            case NEVPNStatus.disconnected:
                return "DISCONNECTED";
           
            case NEVPNStatus.disconnecting:
                return "DISCONNECTING";
            
            case NEVPNStatus.invalid:
                return "";
            
            case NEVPNStatus.reasserting:
                return "REASSERTING";
            
        default:
            return "";
            
        }
    }
    func currentExpireAt() -> String? {
        do {
            let protocolConfiguration = try self.providerManager.protocolConfiguration as? NETunnelProviderProtocol;
            let
            providerConfiguration =  protocolConfiguration?.providerConfiguration
            if providerConfiguration == nil {return nil}
            let expireAt : Data? = providerConfiguration!["expireAt"] as? Data? ?? nil
            return try String(data: expireAt!, encoding: .utf8)
        } catch {
            return nil
        }
    }
    func currentStatus() -> String? {
        
        return onVpnStatusChangedString(notification: self.providerManager.connection.status);
    }

    func configureVPN(ovpnFileContent: String?, expireAt : String?,user : String?,pass : String?,completion:@escaping (_ error : Error?) -> Void) {
        let configData = ovpnFileContent
      self.providerManager?.loadFromPreferences { error in
         if error == nil {
            let tunnelProtocol = NETunnelProviderProtocol()
            tunnelProtocol.serverAddress = ""
            tunnelProtocol.providerBundleIdentifier = self.providerBundleIdentifier
            tunnelProtocol.providerConfiguration = ["ovpn": configData?.data(using: .utf8), "expireAt" : expireAt?.data(using: .utf8),"user" : user?.data(using: .utf8),"pass" : pass?.data(using: .utf8)]
            tunnelProtocol.disconnectOnSleep = false
            self.providerManager.protocolConfiguration = tunnelProtocol
            self.providerManager.localizedDescription = self.localizedDescription // the title of the VPN profile which will appear on Settings
            
            self.providerManager.isEnabled = true
            self.providerManager.saveToPreferences(completionHandler: { (error) in
                  if error == nil  {
                     self.providerManager.loadFromPreferences(completionHandler: { (error) in
                        if error != nil {
                            self.channel.invokeMethod("profileloadfailed", arguments: nil)
                            completion(error);
                            return;
                        }
                        self.channel.invokeMethod("profileloaded", arguments: nil)
                         do {
                            NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil , queue: nil) {
                               notification in

                              

                               let nevpnconn = notification.object as! NEVPNConnection
                               let status = nevpnconn.status
                               self.onVpnStatusChanged(notification: status)
                                
                            }
                           try self.providerManager.connection.startVPNTunnel() // starts the VPN tunnel.
                            completion(nil);
                         } catch let error {
                            self.channel.invokeMethod("profileloadfailed", arguments: nil)
                            completion(error);
                         }
                     })
                  }
            })
          }
       }
    }
    
    func stopVPN() {
        
      self.providerManager.connection.stopVPNTunnel();
        
    }
}
