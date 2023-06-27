//
//  WireGuardObject.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation

public protocol WireGuardDelegate {
    
}

public protocol WireGuard {
    var appGroup: String { get set }
    var tunnelIdentifier: String { get set }
    var tunnelTitle: String { get set }
    
//    var interface: Interface? { get set }
//    var peer: Peer? { get set }
}

extension WireGuard {
    private var defaults: UserDefaults? {
        return UserDefaults(suiteName: appGroup)
    }
}

extension WireGuard {
    /// Interface private key
    public var privateKey: String {
        get {
            defaults?.string(forKey: UserDefaultsKey.interPrivateKey) ?? ""
        }
        set(value) {
            defaults?.set(value, forKey: UserDefaultsKey.interPrivateKey)
        }
    }
    /// Interface address
    public var address: String {
        get {
            defaults?.string(forKey: UserDefaultsKey.interAddress) ?? ""
        }
        set(value) {
            defaults?.set(value, forKey: UserDefaultsKey.interAddress)
        }
    }
    /// Interface dns
    public var dns: String {
        get {
            defaults?.string(forKey: UserDefaultsKey.interDNS) ?? ""
        }
        set(value) {
            defaults?.set(value, forKey: UserDefaultsKey.interDNS)
        }
    }
}

extension WireGuard {
    /// peer private key
    public var publicKey: String {
        get {
            defaults?.string(forKey: UserDefaultsKey.peerPublicKey) ?? ""
        }
        set(value) {
            defaults?.set(value, forKey: UserDefaultsKey.peerPublicKey)
        }
    }
    /// peer allowed ips
    public var allowedIPs: String {
        get {
            defaults?.string(forKey: UserDefaultsKey.peerAllowedIPs) ?? ""
        }
        set(value) {
            defaults?.set(value, forKey: UserDefaultsKey.peerAllowedIPs)
        }
    }
    /// peer end point
    public var endPoint: String {
        get {
            defaults?.string(forKey: UserDefaultsKey.peerEndpoint) ?? ""
        }
        set(value) {
            defaults?.set(value, forKey: UserDefaultsKey.peerEndpoint)
        }
    }
}
