//
//  Notification+.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/28.
//

import Foundation

extension Notification {
    /// The current VPN status.
    public var vpnStatus: VPNStatus {
        get {
            guard let vpnStatus = userInfo?["Status"] as? VPNStatus else {
                fatalError("Notification has no vpnStatus")
            }
            return vpnStatus
        }
        set {
            var newInfo = userInfo ?? [:]
            newInfo["Status"] = newValue
            userInfo = newInfo
        }
    }
    
    /// The triggered VPN error.
    public var vpnError: Error {
        get {
            guard let vpnError = userInfo?["Error"] as? Error else {
                fatalError("Notification has no vpnError")
            }
            return vpnError
        }
        set {
            var newInfo = userInfo ?? [:]
            newInfo["Error"] = newValue
            userInfo = newInfo
        }
    }
}
