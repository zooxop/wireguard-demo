//
//  VPNStatus.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/28.
//
//  Original code from https://github.com/passepartoutvpn/tunnelkit

import Foundation
import NetworkExtension

// Status of a `VPN`.
public enum VPNStatus: String {

    /// VPN is connected.
    case connected

    /// VPN is attempting a connection.
    case connecting

    /// VPN is disconnected.
    case disconnected

    /// VPN is completing a disconnection.
    case disconnecting
}
