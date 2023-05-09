//
//  ContentViewModel.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import SwiftUI
import TunnelKitManager
import TunnelKitWireGuardCore
import TunnelKitWireGuardManager
import SwiftyBeaver

class ContentViewModel: ObservableObject {
    // MARK: - Properties
    @Published var interface: Interface
    @Published var peer: Peer
    @Published var isConnected: Bool = false
    
    private let appGroup = "AWX77X8V5R.group.example.chmun.WireGuardDemo"
    private let tunnelIdentifier = "example.chmun.WireGuardDemo.WGExtension"
    
    private let vpn = NetworkExtensionVPN()
    private(set) var vpnStatus: VPNStatus = .disconnected
    private var wireguardCfg: WireGuard.ProviderConfiguration?
    
    // MARK: - Initializer
    init() {
        // SwiftyBeaver 등록
        let console = ConsoleDestination()
        SwiftyBeaver.addDestination(console)
        
        // 기본 Config 세팅
        let privateKey = UserDefaults.standard.string(forKey: UserDefaultsKey.interPrivateKey) ?? ""
        let address = UserDefaults.standard.string(forKey: UserDefaultsKey.interAddress) ?? ""
        let dns = UserDefaults.standard.string(forKey: UserDefaultsKey.interDNS) ?? "8.8.8.8"

        let publicKey = UserDefaults.standard.string(forKey: UserDefaultsKey.peerPublicKey) ?? ""
        let allowedIPs = UserDefaults.standard.string(forKey: UserDefaultsKey.peerAllowedIPs) ?? "0.0.0.0/0"
        let endpoint = UserDefaults.standard.string(forKey: UserDefaultsKey.peerEndpoint) ?? ""
        
        interface = Interface(privateKey: privateKey,
                              address: address,
                              dns: dns)
        peer = Peer(publicKey: publicKey,
                    allowedIPs: allowedIPs,
                    endPoint: endpoint)
        
        // VPN Observer 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNStatusDidChange(notification:)),
            name: VPNNotification.didChangeStatus,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNDidFail(notification:)),
            name: VPNNotification.didFail,
            object: nil
        )
        
        Task {
            await vpn.prepare()
        }
    }
    
    func saveConfig() {
        UserDefaults.standard.set(interface.privateKey, forKey: UserDefaultsKey.interPrivateKey)
        UserDefaults.standard.set(interface.address, forKey: UserDefaultsKey.interAddress)
        UserDefaults.standard.set(interface.dns, forKey: UserDefaultsKey.interDNS)
        UserDefaults.standard.set(peer.publicKey, forKey: UserDefaultsKey.peerPublicKey)
        UserDefaults.standard.set(peer.allowedIPs, forKey: UserDefaultsKey.peerAllowedIPs)
        UserDefaults.standard.set(peer.endPoint, forKey: UserDefaultsKey.peerEndpoint)
    }
    
    // MARK: - Notification
    @objc private func VPNStatusDidChange(notification: Notification) {
        vpnStatus = notification.vpnStatus
        SwiftyBeaver.info("VPNStatusDidChange: \(vpnStatus)")
        
        switch self.vpnStatus {
        case .connected:
            isConnected = true
            break
        case .disconnected:
            isConnected = false
        default:
            break
        }
    }
    
    @objc private func VPNDidFail(notification: Notification) {
        SwiftyBeaver.info("VPNStatusDidFail: \(notification.vpnError.localizedDescription)")
    }
    
    
    // MARK: - VPN
    
    /// WireGuard Configuration 반환
    private func buildWireGuardConf() -> WireGuard.ProviderConfiguration {
        var allowedIPs: [String] = []
        allowedIPs.append(peer.allowedIPs)  // TODO: string 값 쉼표로 구분해서 배열로 집어넣어줘야 함.
        
        var builder = try! WireGuard.ConfigurationBuilder(interface.privateKey)
        builder.addresses = [interface.address]
        builder.dnsServers = [interface.dns]
        try! builder.addPeer(peer.publicKey, endpoint: peer.endPoint, allowedIPs: allowedIPs)
        
        return WireGuard.ProviderConfiguration("WireGuard Demo App", appGroup: appGroup, configuration: builder.build())
    }
    
    /// start Tunneling
    public func startVpn() {
        wireguardCfg = buildWireGuardConf()
        
        Task {
            try await vpn.reconnect(
                tunnelIdentifier,
                configuration: wireguardCfg!,
                extra: nil,
                after: .never
            )
        }
    }
    
    /// stop Tunneling
    public func stopVpn() {
        Task {
            await vpn.disconnect()
        }
        isConnected = false
    }
    
}
