//
//  WireGuardDemoApp.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import SwiftUI
import SwiftyBeaver

enum WindowSize {
    static let fixedSize = CGSize(width: 400, height: 530)
}

@main
struct WireGuardDemoApp: App {
    
    init() {
//        #if DEBUG
//        let console = ConsoleDestination()
//        SwiftyBeaver.addDestination(console)
//        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: WindowSize.fixedSize.width, minHeight: WindowSize.fixedSize.height)
                .frame(maxWidth: WindowSize.fixedSize.width, maxHeight: WindowSize.fixedSize.height)
        }
        .contentSizedWindowResizability()
    }
}
