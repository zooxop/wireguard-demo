//
//  WireGuardInterface.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation
import SwiftyBeaver

/// WireGuard protocol Builder
public class WireGuardBuilder: WireGuard {
    public var appGroup: String
    public var tunnelIdentifier: String
    public var tunnelTitle: String
    
    init(appGroup: String, tunnelIdentifier: String, tunnelTitle: String) {
        self.appGroup = appGroup
        self.tunnelIdentifier = tunnelIdentifier
        self.tunnelTitle = tunnelTitle
    }
    
    /// UserDefauts 공유를 위해 AppGroup만 있어도 상관없는 경우
    init(appGroup: String) {
        self.appGroup = appGroup
        self.tunnelTitle = ""
        self.tunnelIdentifier = ""
    }
}
