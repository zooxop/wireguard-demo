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
    var runtimeLog: RuntimeLog?
    
    private let runtimeLogBuilder: RuntimeLogBuilder = RuntimeLogBuilder()
    
    init(wireGuard: WireGuard) {
        self.wireGuard = wireGuard
        self.vpn = VPNBuilder(wireGuard: wireGuard)
    }
    
    // MARK: VPN
    func getRuntimeLog(completion: @escaping (RuntimeLog?) -> Void) {
        self.vpn.handleAppMessage(code: TunnelMessageCode.getRuntimeLogs) { responseData in
            guard let responseData = responseData else {
                completion(nil)
                return
            }
            completion(self.runtimeLogBuilder.build(responseData))
        }
    }
    
    /// AllowedIPs 를 0.0.0.0/0 으로 변경.
    func updateForAll(completion: @escaping (Bool) -> Void) {
        self.vpn.handleAppMessage(code: TunnelMessageCode.updateForAll) { responseData in
            guard let _ = responseData else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// AllowedIPs 를 192.168.0.2/32 로 변경.
    func updateForSingle(completion: @escaping (Bool) -> Void) {
        self.vpn.handleAppMessage(code: TunnelMessageCode.updateForSingle) { responseData in
            guard let _ = responseData else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func send() {
        self.vpn.handleAppMessage(code: .getLog) { responseData in
            guard let _ = responseData else {
                return
            }
        }
    }
}
