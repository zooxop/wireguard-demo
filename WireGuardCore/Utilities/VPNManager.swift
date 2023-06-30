//
//  VPNManager.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation
import NetworkExtension
import SwiftyBeaver

// TODO: VPNStatus 옵저빙
// TODO: 연결 상태에서, 서버에서 Peer 정보 삭제시키는 경우를 감지하는 기능
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
}
