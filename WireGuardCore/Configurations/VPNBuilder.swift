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
        
        self.addNotification()
    }
    
    init(wireGuard: WireGuard) {
        self.tunnelTitle = wireGuard.tunnelTitle
        self.tunnelIdentifier = wireGuard.tunnelIdentifier
        self.endPoint = wireGuard.endPoint
        self.interface = wireGuard.interface
        self.peer = wireGuard.peer
        
        self.addNotification()
    }
    
    private func addNotification() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(vpnDidUpdate(_:)), name: .NEVPNStatusDidChange, object: nil)
    }
    
    @objc func vpnDidUpdate(_ notification: Notification) {
        guard let connection = notification.object as? NETunnelProviderSession else {
            return
        }
        notifyStatus(connection)
    }
    
    private func notifyStatus(_ connection: NETunnelProviderSession) {
        guard let _ = connection.manager.localizedDescription else {
            return
        }

        var notification = Notification(name: VPNNotification.didChangeStatus)
        notification.vpnStatus = connection.status.wrappedStatus
        NotificationCenter.default.post(notification)
    }
}

private extension NEVPNStatus {
    var wrappedStatus: VPNStatus {
        switch self {
        case .connected:
            return .connected
            
        case .connecting, .reasserting:
            return .connecting
            
        case .disconnecting:
            return .disconnecting
            
        case .disconnected, .invalid:
            return .disconnected
            
        @unknown default:
            return .disconnected
        }
    }
}
