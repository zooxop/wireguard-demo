//
//  ContentViewModel.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import SwiftUI
import TunnelKitManager

class ContentViewModel: ObservableObject {
    @Published var interface: Interface
    @Published var peer: Peer
    
    private let appGroup = "AWX77X8V5R.group.example.chmun.WireGuardDemo"
    private let tunnelIdentifier = "example.chmun.WireGuardDemo.WGExtension"
    
    private let vpn = NetworkExtensionVPN()
    
    init() {
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
    }
    
    func saveConfig() {
        UserDefaults.standard.set(interface.privateKey, forKey: UserDefaultsKey.interPrivateKey)
        UserDefaults.standard.set(interface.address, forKey: UserDefaultsKey.interAddress)
        UserDefaults.standard.set(interface.dns, forKey: UserDefaultsKey.interDNS)
        UserDefaults.standard.set(peer.publicKey, forKey: UserDefaultsKey.peerPublicKey)
        UserDefaults.standard.set(peer.allowedIPs, forKey: UserDefaultsKey.peerAllowedIPs)
        UserDefaults.standard.set(peer.endPoint, forKey: UserDefaultsKey.peerEndpoint)
    }
}