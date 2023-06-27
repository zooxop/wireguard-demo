//
//  RuntimeUpdater.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation
import SwiftyBeaver

public protocol RuntimeUpdaterProtocol {
    init(timeInterval: TimeInterval, _ event: @escaping () -> Void)
    func startUpdating()
    func stopUpdating()
}

public class RuntimeUpdater: RuntimeUpdaterProtocol {
    private var timer: Timer? {
        didSet(oldValue) {
            oldValue?.invalidate()
        }
    }
    
    public required init(timeInterval: TimeInterval, _ event: @escaping () -> Void) {
        self.timer = Timer(timeInterval: timeInterval, repeats: true) { _ in
            event()
        }
    }
    
    deinit {
        self.timer = nil
    }
    
    public func startUpdating() {
        RunLoop.main.add(self.timer!, forMode: .common)
    }
    
    public func stopUpdating() {
        self.timer?.invalidate()
    }
}
