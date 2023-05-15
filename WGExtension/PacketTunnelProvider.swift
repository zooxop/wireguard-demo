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
        guard messageData.count == 1, let code = TunnelMessageCode(rawValue: messageData[0]) else {
            completionHandler?(nil)
            return
        }

        switch code {
        case .getTransferredByteCount:
            self.getTransferredByteCount { transferredByteCount in
                completionHandler?(transferredByteCount?.data)
            }
        default:
            return
        }
    }
    
    private func getTransferredByteCount(completionHandler: @escaping (DataCount?) -> Void) {
        self.adapter.getRuntimeConfiguration { settings in
            let tunnelConfiguration = self.cfg.configuration.tunnelConfiguration
            
            
            guard let settings = settings,
                  let runtimeConfig = try? WireGuard.Configuration(fromUapiConfig: settings, basedOn: tunnelConfiguration) else {
                completionHandler(nil)
                return
            }
            let rxBytesTotal = runtimeConfig.peers.reduce(0) { $0 + ($1.rxBytes ?? 0) }
            let txBytesTotal = runtimeConfig.peers.reduce(0) { $0 + ($1.txBytes ?? 0) }
            let transferredByteCount = DataCount(UInt(rxBytesTotal), UInt(txBytesTotal))// TransferredByteCount(inbound: rxBytesTotal, outbound: txBytesTotal)
            completionHandler(transferredByteCount)
        }
    }
}
