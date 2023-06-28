//
//  ContentViewModel.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import Foundation
import NetworkExtension
import SwiftyBeaver

class ContentViewModel: ObservableObject {
    
    // MARK: Published
    @Published var isConnected: Bool = false
    @Published var inbound: Int = 0
    @Published var outbound: Int = 0
    
    // MARK: private let
    private let appGroup = "AWX77X8V5R.group.example.chmun.WireGuardDemo"
    private let tunnelIdentifier = "example.chmun.WireGuardDemo.WGExtension"
    private let tunnelTitle = "WireGuard Demo App"
    
    // MARK: Private var
    private var runtimeUpdater: RuntimeUpdaterProtocol?
    
    // MARK: Public var
    public var wireGuard: WireGuard
    public var vpnManager: VPNManager
    
    // MARK: - Initializer
    init() {
        self.wireGuard = WireGuardInterface(appGroup: appGroup,
                                            tunnelIdentifier: tunnelIdentifier,
                                            tunnelTitle: tunnelTitle)
        self.vpnManager = VPNManager(wireGuard: self.wireGuard)
        
        self.runtimeUpdater = RuntimeUpdater(timeInterval: 3) { [self] in
            self.getTransferredByteCount()
        }
        
        #if DEBUG
        let console = ConsoleDestination()
        SwiftyBeaver.addDestination(console)
        #endif
    }
    
    deinit {
        self.runtimeUpdater = nil
        self.stopVpn()
    }
    
    // MARK: - VPN
    
    /// start Tunneling
    func startVpn() {
        SwiftyBeaver.info("Start VPN")
        self.turnOnTunnel { isSuccess in
            if isSuccess {
                self.isConnected = isSuccess
                self.runtimeUpdater?.startUpdating()
            }
        }
    }
    
    /// stop Tunneling
    func stopVpn() {
        self.isConnected = false
        self.turnOffTunnel()
        self.runtimeUpdater?.stopUpdating()
        self.inbound = 0
        self.outbound = 0
    }
    
    func installVpnInterface() {
        vpnManager.vpn.install { result in
            print("install : \(result.description)")
        }
    }
    
    func startExtensionProcess() {
        vpnManager.vpn.prepare()
    }
    
    private func turnOnTunnel(completionHandler: @escaping (Bool) -> Void) {
        let result = vpnManager.vpn.turnOnTunnel()
        SwiftyBeaver.info("turn on result : \(result.description)")
        completionHandler(result)
    }
    
    private func turnOffTunnel() {
        let result = vpnManager.vpn.turnOffTunnel()
        SwiftyBeaver.info("turn off result : \(result.description)")
    }
    
    public func getTransferredByteCount() {
        vpnManager.getTransferredByteCount { inbound, outbound in
            self.inbound = inbound
            self.outbound = outbound
        }
    }
}
