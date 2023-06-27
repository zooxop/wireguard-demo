//
//  WireGuardInterface.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation
import SwiftyBeaver

public class WireGuardInterface: WireGuard {
    public var appGroup: String
    public var tunnelIdentifier: String
    public var tunnelTitle: String
    
    init(appGroup: String, tunnelIdentifier: String, tunnelTitle: String) {
        self.appGroup = appGroup
        self.tunnelIdentifier = tunnelIdentifier
        self.tunnelTitle = tunnelTitle
    }
    
    public var interface: Interface? {
        if privateKey == "" || address == "" || dns == "" {
            SwiftyBeaver.info("Interface information has something wrong.")
            return nil
        }
        
        return Interface(privateKey: privateKey,
                         address: address,
                         dns: dns)
    }
    public var peer: Peer? {
        if publicKey == "" || allowedIPs == "" || endPoint == "" {
            SwiftyBeaver.info("Peer information has something wrong.")
            return nil
        }
        
        return Peer(publicKey: publicKey,
                    allowedIPs: allowedIPs,
                    endPoint: endPoint)
    }
}
