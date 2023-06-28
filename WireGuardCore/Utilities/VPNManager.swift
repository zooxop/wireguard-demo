//
//  VPNManager.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation
import NetworkExtension
import SwiftyBeaver

class VPNManager: ObservableObject {
    var wireGuard: WireGuard
    var vpn: VPN
//    var wireGuardConfig: WireGuardConfig.WgQuickConfig?
    
    //MARK: VPN protocol
    var tunnelManager: NETunnelProviderManager?
    
    
    init(wireGuard: WireGuard) {
        self.wireGuard = wireGuard
        self.vpn = VPNInterface(wireGuard: wireGuard)
    }
    
    // MARK: VPN
    public func prepare() {

    }
}
