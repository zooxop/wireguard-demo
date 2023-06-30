//
//  RuntimeLog.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/30.
//

import Foundation

struct RuntimeLog {
    var privateKey: String
    var listenPort: Int
    var publicKey: String
    var presharedKey: String
    var protocolVersion: Int
    var endpoint: String
    var lastHandshakeTimeSec: Int
    var lastHandshakeTimeNsec: Int
    var txBytes: Int
    var rxBytes: Int
    var persistentKeepaliveInterval: Int
    var allowedIP: String
}

class RuntimeLogBuilder {
    func build(_ data: Data) -> RuntimeLog {
        var runtimeLog = RuntimeLog(privateKey: "",
                                    listenPort: 0,
                                    publicKey: "",
                                    presharedKey: "",
                                    protocolVersion: 0,
                                    endpoint: "",
                                    lastHandshakeTimeSec: 0,
                                    lastHandshakeTimeNsec: 0,
                                    txBytes: 0,
                                    rxBytes: 0,
                                    persistentKeepaliveInterval: 0,
                                    allowedIP: "")
        let strLog = String(decoding: data, as: UTF8.self)
        
        let lines = strLog.components(separatedBy: "\n")
        
        for line in lines {
            let components = line.components(separatedBy: "=")
            
            if components.count == 2 {
                let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                switch key {
                case "private_key":
                    runtimeLog = RuntimeLog(privateKey: value,
                                            listenPort: 0,
                                            publicKey: "",
                                            presharedKey: "",
                                            protocolVersion: 0,
                                            endpoint: "",
                                            lastHandshakeTimeSec: 0,
                                            lastHandshakeTimeNsec: 0,
                                            txBytes: 0,
                                            rxBytes: 0,
                                            persistentKeepaliveInterval: 0,
                                            allowedIP: "")
                case "listen_port":
                    if let listenPort = Int(value) {
                        runtimeLog.listenPort = listenPort
                    }
                case "public_key":
                    runtimeLog.publicKey = value
                case "preshared_key":
                    runtimeLog.presharedKey = value
                case "protocol_version":
                    if let protocolVersion = Int(value) {
                        runtimeLog.protocolVersion = protocolVersion
                    }
                case "endpoint":
                    runtimeLog.endpoint = value
                case "last_handshake_time_sec":
                    if let lastHandshakeTimeSec = Int(value) {
                        runtimeLog.lastHandshakeTimeSec = lastHandshakeTimeSec
                    }
                case "last_handshake_time_nsec":
                    if let lastHandshakeTimeNsec = Int(value) {
                        runtimeLog.lastHandshakeTimeNsec = lastHandshakeTimeNsec
                    }
                case "tx_bytes":
                    if let txBytes = Int(value) {
                        runtimeLog.txBytes = txBytes
                    }
                case "rx_bytes":
                    if let rxBytes = Int(value) {
                        runtimeLog.rxBytes = rxBytes
                    }
                case "persistent_keepalive_interval":
                    if let persistentKeepaliveInterval = Int(value) {
                        runtimeLog.persistentKeepaliveInterval = persistentKeepaliveInterval
                    }
                case "allowed_ip":
                    runtimeLog.allowedIP = value
                default:
                    break
                }
            }
        }
        
        return runtimeLog
    }
}


/* example
 private_key=e0e1dd4362bbb747c2d9e08ab3d7b83c14dfd1d2b68dd0a628ba2b9209551459
 listen_port=61892
 public_key=da0cd302ee7ff88c0ff7ee100664403c4a0eeb5412a3e31f372811774029704e
 preshared_key=0000000000000000000000000000000000000000000000000000000000000000
 protocol_version=1
 endpoint=192.168.0.100:51820
 last_handshake_time_sec=1688082372
 last_handshake_time_nsec=733270000
 tx_bytes=50628
 rx_bytes=107228
 persistent_keepalive_interval=0
 allowed_ip=0.0.0.0/0
 */
