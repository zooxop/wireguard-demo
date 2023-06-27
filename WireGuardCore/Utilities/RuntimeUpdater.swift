//
//  RuntimeUpdater.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/27.
//

import Foundation

public protocol RuntimeUpdaterProtocol {
    init(timeInterval: TimeInterval, _ event: @escaping () -> Void)
    func startUpdating()
    func stopUpdating()
}

public class RuntimeUpdater: RuntimeUpdaterProtocol {
    private let timeInterval: TimeInterval
    private let event: () -> Void
    private var timer: Timer? {
        didSet(oldValue) {
            oldValue?.invalidate()
        }
    }
    
    public required init(timeInterval: TimeInterval, _ event: @escaping () -> Void) {
        self.timeInterval = timeInterval
        self.event = event
    }
    
    deinit {
        self.timer = nil
    }
    
    public func startUpdating() {
        self.timer = Timer(timeInterval: self.timeInterval, repeats: true) { _ in
            self.event()
        }
        RunLoop.main.add(self.timer!, forMode: .common)
    }
    
    public func stopUpdating() {
        self.timer?.invalidate()
    }
}
