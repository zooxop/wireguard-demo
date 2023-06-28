//
//  ContentViewModel.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import Foundation
import NetworkExtension
import SwiftyBeaver

// TODO: VPNManager 개발
// TODO: 연결 프로세스를 TunnelProvider에서 실행
// TODO: 공통 코드들 한곳으로 몰기
class ContentViewModel: ObservableObject {
    
    // MARK: Published
    @Published var vpnManager: VPNManager
    @Published var isConnected: Bool = false
    @Published var inbound: Int = 0
    @Published var outbound: Int = 0
    
    // MARK: private let
    private let appGroup = "AWX77X8V5R.group.example.chmun.WireGuardDemo"
    private let tunnelIdentifier = "example.chmun.WireGuardDemo.WGExtension"
    private let tunnelTitle = "WireGuard Demo App"
    
    // MARK: Private var
    private var runtimeUpdater: RuntimeUpdaterProtocol?
    private var tunnelManager: NETunnelProviderManager?
    
    // MARK: Public var
    public var wireGuard: WireGuard
    
    // MARK: - Initializer
    init() {
        self.wireGuard = WireGuardInterface(appGroup: appGroup,
                                            tunnelIdentifier: tunnelIdentifier,
                                            tunnelTitle: tunnelTitle)
        self.vpnManager = VPNManager(wireGuard: self.wireGuard)
        
        self.runtimeUpdater = RuntimeUpdater(timeInterval: 3) { [self] in
            getTransferredByteCount()
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
    }
    
    func getTransferredByteCount() {
        guard let session: NETunnelProviderSession = tunnelManager?.connection as? NETunnelProviderSession else {
            return
        }
        do {
            // MARK: !!!! session.sendProviderMessage() 메서드만 호출시켜도, Extension 프로세스를 띄울 수 있다.
            try session.sendProviderMessage(TunnelMessageCode.getTransferredByteCount.data) { responseData in
                
                guard let responseData = responseData else {
                    return
                }
                let byteCount = TransferredByteCount(from: responseData)
                self.inbound = Int(byteCount.inbound)
                self.outbound = Int(byteCount.outbound)
            }
        } catch {
            print(error)
        }
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
}
