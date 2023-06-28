//
//  WireGuardInterface.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation
import SwiftyBeaver

public class WireGuardInterface: WireGuard {
    public var appGroup: String
    public var tunnelIdentifier: String
    public var tunnelTitle: String
    
    init(appGroup: String, tunnelIdentifier: String, tunnelTitle: String) {
        self.appGroup = appGroup
        self.tunnelIdentifier = tunnelIdentifier
        self.tunnelTitle = tunnelTitle
    }
}
