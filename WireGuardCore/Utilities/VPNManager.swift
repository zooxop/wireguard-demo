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
    
    init(wireGuard: WireGuard) {
        self.wireGuard = wireGuard
        self.vpn = VPNBuilder(wireGuard: wireGuard)
    }
    
    // MARK: VPN
    func getTransferredByteCount(completion: @escaping (Int, Int) -> Void) {
        self.vpn.handleAppMessage(code: TunnelMessageCode.getTransferredByteCount) { responseData in
            guard let responseData = responseData else {
                return
            }
            let byteCount = TransferredByteCount(from: responseData)
            completion(Int(byteCount.inbound), Int(byteCount.outbound))
        }
    }
    
    func getLog(completion: @escaping () -> Void) {
        // TODO: 수정 해야함.
        self.vpn.handleAppMessage(code: TunnelMessageCode.getLog) { responseData in
            guard let _ = responseData else {
                return
            }
        }
    }
}
