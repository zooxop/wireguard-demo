//
//  VPNInterface.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/28.
//

import Foundation
import NetworkExtension
import SwiftyBeaver

public class VPNBuilder: VPN {
    public var tunnelTitle: String
    public var tunnelIdentifier: String
    public var endPoint: String
    public var interface: Interface?
    public var peer: Peer?
    
    public var tunnelManager: NETunnelProviderManager?
    
    init(tunnelTitle: String, tunnelIdentifier: String, endPoint: String, interface: Interface, peer: Peer) {
        self.tunnelTitle = tunnelTitle
        self.tunnelIdentifier = tunnelIdentifier
        self.endPoint = endPoint
        self.interface = interface
        self.peer = peer
    }
    
    init(wireGuard: WireGuard) {
        self.tunnelTitle = wireGuard.tunnelTitle
        self.tunnelIdentifier = wireGuard.tunnelIdentifier
        self.endPoint = wireGuard.endPoint
        self.interface = wireGuard.interface
        self.peer = wireGuard.peer
    }
}
