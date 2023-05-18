//
//  PacketTunnelProvider.swift
//  WGExtension
//
//  Created by 문철현 on 2023/05/09.
//

import NetworkExtension
import TunnelKitCore
import TunnelKitWireGuardCore
import TunnelKitWireGuardAppExtension

class PacketTunnelProvider: WireGuardTunnelProvider {
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        guard messageData.count == 1, let _ = TunnelMessageCode(rawValue: messageData[0]) else {
            completionHandler?(nil)
            return
        }
        
        super.handleAppMessage(messageData) { data in
            completionHandler?(data)
        }
    }
}
