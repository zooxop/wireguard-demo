//
//  VPNManager.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation
import SwiftyBeaver

class VPNManager: WireGuard, ObservableObject {
    var appGroup: String
    var tunnelIdentifier: String
    var tunnelTitle: String
    
    init(appGroup: String, tunnelIdentifier: String, tunnelTitle: String) {
        self.appGroup = appGroup
        self.tunnelIdentifier = tunnelIdentifier
        self.tunnelTitle = tunnelTitle
    }
    
    private func makeInterface() -> Interface? {
        if privateKey == "" {
            SwiftyBeaver.info("privateKey of Interface is empty")
            return nil
        }
        if address == "" {
            SwiftyBeaver.info("address of Interface is empty")
            return nil
        }
        if dns == "" {
            SwiftyBeaver.info("dns of Interface is empty")
            return nil
        }
        
        return Interface(privateKey: privateKey,
                         address: address,
                         dns: dns)
    }
    private func makePeer() -> Peer? {
        if publicKey == "" {
            SwiftyBeaver.info("publicKey of Peer is empty")
            return nil
        }
        
        if allowedIPs == "" {
            SwiftyBeaver.info("allowedIPs of Peer is empty")
            return nil
        }
        if endPoint == "" {
            SwiftyBeaver.info("endPoint of Peer is empty")
            return nil
        }
        
        return Peer(publicKey: publicKey,
                    allowedIPs: allowedIPs,
                    endPoint: endPoint)
    }
    
    public func makeWgQuickConfig() -> String? {
        guard let interface = self.makeInterface(),
              let peer = self.makePeer() else {
            SwiftyBeaver.warning("Interface or Peer information is not initialized yet.")
            return nil
        }
        
        return """
        [Interface]
        PrivateKey = \(interface.privateKey)
        Address = \(interface.address)
        DNS = \(interface.dns)

        [Peer]
        PublicKey = \(peer.publicKey)
        AllowedIPs = \(peer.allowedIPs)
        Endpoint = \(peer.endPoint)
        """
    }
    
    // MARK: VPN
    public func prepare() {
//        guard let session: NETunnelProviderSession = tunnelManager?.connection as? NETunnelProviderSession else {
//            return
//        }
//        do {
//            // MARK: !!!! session.sendProviderMessage() 메서드만 호출시켜도, Extension 프로세스를 띄울 수 있다.
//            try session.sendProviderMessage(TunnelMessageCode.startProcess.data) { responseData in
//                print("캬캬캬캬")
//            }
//        } catch {
//            print(error)
//        }
    }
}

/*
 peer = Peer(publicKey: publicKey,
             allowedIPs: allowedIPs,
             endPoint: endpoint)
 */
