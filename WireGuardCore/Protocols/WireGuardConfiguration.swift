//
//  WireGuardObject.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation

public protocol WireGuardConfiguration {
    var appGroup: String { get }
    var tunnelIdentifier: String { get }
    var tunnelTitle: String { get }
    
    var interface: Interface { get set }
    var peer: Peer { get set }
}
