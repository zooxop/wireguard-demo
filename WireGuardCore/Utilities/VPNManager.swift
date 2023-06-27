//
//  VPNManager.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation
import NetworkExtension
import SwiftyBeaver

class VPN {
    private var tunnelManager: NETunnelProviderManager?
}

class VPNManager: ObservableObject {
    var wireGuard: WireGuard
    var wireGuardConfig: WireGuardConfig.WgQuickConfig?
    
    init(wireGuard: WireGuard) {
        self.wireGuard = wireGuard
    }
    
    // MARK: VPN
    public func prepare() {
        guard let wireGuardConfig = wireGuardConfig else {
            SwiftyBeaver.warning("WireGuard Config를 먼저 생성해야 함.")
            return
        }
        print(wireGuardConfig.description)
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
