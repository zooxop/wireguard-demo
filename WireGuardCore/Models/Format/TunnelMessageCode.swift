//
//  TunnelMessageCode.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation

enum TunnelMessageCode: UInt8 {
    case getTransferredByteCount = 0 // Returns TransferredByteCount as Data
    case getNetworkAddresses = 1 // Returns [String] as JSON
    case getLog = 2 // Returns UTF-8 string
    case getConnectedDate = 3 // Returns UInt64 as Data
    case startProcess = 4 // to start Network Extension process

    var data: Data { Data([rawValue]) }
}
