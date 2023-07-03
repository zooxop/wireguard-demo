//
//  WireGuardConfig.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation

public protocol WireGuardConfig {
    typealias WgQuickConfig = String
}

class WireGuardConfigBuilder: WireGuardConfig {
    var interface: Interface
    var peer: Peer
    
    required init(interface: Interface, peer: Peer) {
        self.interface = interface
        self.peer = peer
    }
    
    func build(keepAlive: Int) -> WgQuickConfig? {
        return """
        [Interface]
        PrivateKey = \(interface.privateKey)
        Address = \(interface.address)
        DNS = \(interface.dns)

        [Peer]
        PublicKey = \(peer.publicKey)
        AllowedIPs = \(peer.allowedIPs)
        Endpoint = \(peer.endPoint)
        PersistentKeepalive = \(keepAlive.description)
        """
    }
}
