import NetworkExtension
import OpenVPNAdapter
import os

// Extend NEPacketTunnelFlow to adopt OpenVPNAdapterPacketFlow protocol so that
// `self.packetFlow` could be sent to `completionHandler` callback of OpenVPNAdapterDelegate
// method openVPNAdapter(openVPNAdapter:configureTunnelWithNetworkSettings:completionHandler).
extension NEPacketTunnelFlow: OpenVPNAdapterPacketFlow {}

class PacketTunnelProvider: NEPacketTunnelProvider {

    lazy var vpnAdapter: OpenVPNAdapter = {
        let adapter = OpenVPNAdapter()
        adapter.delegate = self

        return adapter
    }()

    let vpnReachability = OpenVPNReachability()

    var startHandler: ((Error?) -> Void)?
    var stopHandler: (() -> Void)?

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // There are many ways to provide OpenVPN settings to the tunnel provider. For instance,
        // you can use `options` argument of `startTunnel(options:completionHandler:)` method or get
        // settings from `protocolConfiguration.providerConfiguration` property of `NEPacketTunnelProvider`
        // class. Also you may provide just content of a ovpn file or use key:value pairs
        // that may be provided exclusively or in addition to file content.

        // In our case we need providerConfiguration dictionary to retrieve content
        // of the OpenVPN configuration file. Other options related to the tunnel
        // provider also can be stored there.
        guard
            let protocolConfiguration = protocolConfiguration as? NETunnelProviderProtocol,
            let providerConfiguration = protocolConfiguration.providerConfiguration
        else {
            fatalError()
        }

        guard let ovpnFileContent: Data = providerConfiguration["ovpn"] as? Data else {
            fatalError()
        }
        let expireAt : Data? = providerConfiguration["expireAt"] as? Data? ?? nil
        

        let configuration = OpenVPNConfiguration()
        configuration.fileContent = ovpnFileContent
        

        // Uncomment this line if you want to keep TUN interface active during pauses or reconnections
        // configuration.tunPersist = true

        // Apply OpenVPN configuration
        let properties: OpenVPNProperties
        do {
            properties = try vpnAdapter.apply(configuration: configuration)
        } catch {
            completionHandler(error)
            return
        }

        // Provide credentials if needed
        if !properties.autologin {
            // If your VPN configuration requires user credentials you can provide them by
            // `protocolConfiguration.username` and `protocolConfiguration.passwordReference`
            // properties. It is recommended to use persistent keychain reference to a keychain
            // item containing the password.

            guard let username: String = protocolConfiguration.username else {
                fatalError()
            }

            // Retrieve a password from the keychain
            let password: String = "1234"

            let credentials = OpenVPNCredentials()
            credentials.username = username
            credentials.password = password

            do {
                try vpnAdapter.provide(credentials: credentials)
            } catch {
                completionHandler(error)
                return
            }
        }

        // Checking reachability. In some cases after switching from cellular to
        // WiFi the adapter still uses cellular data. Changing reachability forces
        // reconnection so the adapter will use actual connection.
        vpnReachability.startTracking { [weak self] status in
            guard status == .reachableViaWiFi else { return }
            self?.vpnAdapter.reconnect(afterTimeInterval: 5)
        }

        // Establish connection and wait for .connected event
//        let connectedDate = Date()
//        if expireAt != nil {
//            var expireAtDate:Date!;
//            let formatter = DateFormatter();
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
//            formatter.timeZone = TimeZone(abbreviation: "UTC");
//            expireAtDate = formatter.date(from: String(decoding: expireAt!, as: UTF8.self));
//            let diffComponents = Calendar.current.dateComponents([.second], from: connectedDate, to: expireAtDate)
//            var diffSeconds = diffComponents.second
//            diffSeconds = diffSeconds! + 60
//            if diffSeconds! < 0 {
//                return;
//            }
//            os_log("foo: %@", diffSeconds!)
//            Timer.scheduledTimer(withTimeInterval: TimeInterval(diffSeconds!), repeats: false) { (timer : Timer) in
//                self.stopTunnel(with: NEProviderStopReason.idleTimeout) {
//                    
//                }
//            }
//        }
        
        startHandler = completionHandler
        vpnAdapter.connect(using: packetFlow)
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        stopHandler = completionHandler

        if vpnReachability.isTracking {
            vpnReachability.stopTracking()
        }

        vpnAdapter.disconnect()
    }

}

extension PacketTunnelProvider: OpenVPNAdapterDelegate {

    // OpenVPNAdapter calls this delegate method to configure a VPN tunnel.
    // `completionHandler` callback requires an object conforming to `OpenVPNAdapterPacketFlow`
    // protocol if the tunnel is configured without errors. Otherwise send nil.
    // `OpenVPNAdapterPacketFlow` method signatures are similar to `NEPacketTunnelFlow` so
    // you can just extend that class to adopt `OpenVPNAdapterPacketFlow` protocol and
    // send `self.packetFlow` to `completionHandler` callback.
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, configureTunnelWithNetworkSettings networkSettings: NEPacketTunnelNetworkSettings?, completionHandler: @escaping (Error?) -> Void) {
        // In order to direct all DNS queries first to the VPN DNS servers before the primary DNS servers
        // send empty string to NEDNSSettings.matchDomains
        networkSettings?.dnsSettings?.matchDomains = [""]

        // Set the network settings for the current tunneling session.
        setTunnelNetworkSettings(networkSettings, completionHandler: completionHandler)
    }

    // Process events returned by the OpenVPN library
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleEvent event: OpenVPNAdapterEvent, message: String?) {
        switch event {
        case .connected:
            if reasserting {
                reasserting = false
            }

            guard let startHandler = startHandler else { return }

            startHandler(nil)
            self.startHandler = nil

        case .disconnected:
            guard let stopHandler = stopHandler else { return }

            if vpnReachability.isTracking {
                vpnReachability.stopTracking()
            }

            stopHandler()
            self.stopHandler = nil

        case .reconnecting:
            reasserting = true

        default:
            break
        }
    }

    // Handle errors thrown by the OpenVPN library
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleError error: Error) {
        // Handle only fatal errors
        guard let fatal = (error as NSError).userInfo[OpenVPNAdapterErrorFatalKey] as? Bool, fatal == true else {
            return
        }

        if vpnReachability.isTracking {
            vpnReachability.stopTracking()
        }

        if let startHandler = startHandler {
            startHandler(error)
            self.startHandler = nil
        } else {
            cancelTunnelWithError(error)
        }
    }

    // Use this method to process any log message returned by OpenVPN library.
    func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleLogMessage logMessage: String) {
        // Handle log messages
    }

}

