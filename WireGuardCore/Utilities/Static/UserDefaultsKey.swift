//
//  UserDefaults.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import Foundation

class UserDefaultsKey {
    static let interPrivateKey = "interPrivateKey"
    static let interAddress = "interAddress"
    static let interDNS = "interDNS"
    
    static let peerPublicKey = "peerPublicKey"
    static let peerAllowedIPs = "peerAllowedIPs"
    static let peerEndpoint = "peerEndpoint"
}
