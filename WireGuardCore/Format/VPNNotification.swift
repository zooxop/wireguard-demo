//
//  VPNNotification.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/28.
//

import Foundation

/// VPN notifications.
public struct VPNNotification {
    /// The VPN did change its status.
    public static let didChangeStatus = Notification.Name("VPNDidChangeStatus")

    /// The VPN triggered some error.
    public static let didFail = Notification.Name("VPNDidFail")
}
