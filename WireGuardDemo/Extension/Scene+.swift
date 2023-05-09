//
//  Scene+.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import SwiftUI

extension Scene {
    func contentSizedWindowResizability() -> some Scene {
        if #available(macOS 13.0, *) {
            return self.windowResizability(.contentSize)
        } else {
            return self
        }
    }
}
