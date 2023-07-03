//
//  ContentViewModel.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import Foundation
import NetworkExtension
import SwiftyBeaver
import Network

class ContentViewModel: ObservableObject {
    
    // MARK: Published
    @Published var isConnected: Bool = false
    @Published var inbound: Int = 0
    @Published var outbound: Int = 0
    @Published var tunnelHandshakeTimestampAgo: Int = 0
    @Published var currentIP: String = "" {
        didSet(oldValue) {
            if self.currentIP != oldValue {
                print("current : ", self.currentIP, "old : ", oldValue)
                print("재연결 Notification post 하면 됨. (단, VPN 커넥션 중일 때만.)")
            }
        }
    }
    
    let networkMonitor = NWPathMonitor()
    
    // MARK: private let
    private let appGroup = "AWR77X8V5R.group.example.chmun.WireGuardDemo"
    private let tunnelIdentifier = "example.chmun.WireGuardDemo.WGExtension"
    private let tunnelTitle = "WireGuard Demo App"
    
    // MARK: Private var
    private var runtimeUpdater: RuntimeUpdaterProtocol?
    private var vpnStatus: VPNStatus = .disconnected
    
    // MARK: Public var
    public var wireGuard: WireGuard
    public var vpnManager: VPNManager
    
    // MARK: - Initializer
    init() {
        self.wireGuard = WireGuardBuilder(appGroup: appGroup,
                                            tunnelIdentifier: tunnelIdentifier,
                                            tunnelTitle: tunnelTitle)
        self.vpnManager = VPNManager(wireGuard: self.wireGuard)
        
        self.runtimeUpdater = RuntimeUpdater(timeInterval: 5) { [self] in
            self.updateRuntimeLog()
        }
        
        #if DEBUG
        let console = ConsoleDestination()
        SwiftyBeaver.addDestination(console)
        #endif
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNStatusDidChange(notification:)),
            name: .NEVPNStatusDidChange,
            object: nil
        )
        self.getIPAddress()
        self.setNetworkMonitor()
    }
    
    deinit {
        self.runtimeUpdater = nil
        self.stopVpn()
    }
    
    func setNetworkMonitor() {
        self.networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("connected : ", path.status)
                self.getIPAddress()
            } else {
                print("끊김")
            }
        }
        self.networkMonitor.start(queue: DispatchQueue.global())
    }
    
    func getIPAddress() {
        getPublicIP(url: PublicIPAPIURLs.ipv4.amazonaws.rawValue) { (ip, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let ip = ip {
                DispatchQueue.main.async {
                    self.currentIP = ip
                }
            }
        }
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
        self.tunnelHandshakeTimestampAgo = 0
    }
    
    /// install VPN Interface at [Settings > VPN]
    func installVpnInterface() {
        vpnManager.vpn.install { result in
            print("install : \(result.description)")
        }
    }
    
    /// launch NetworkExtension process
    func startExtensionProcess() {
        vpnManager.vpn.prepare()
    }
    
    /// update runtime informations from WireGuardConfiguration
    func updateRuntimeLog() {
        vpnManager.getRuntimeLog { runtimeLog in
            guard let runtimeLog = runtimeLog else {
                return
            }
            self.setTransferredByteCount(inbound: runtimeLog.rxBytes, outbound: runtimeLog.txBytes)
            self.calculateLastHandshakeTime(unixTime: runtimeLog.lastHandshakeTimeSec)
        }
    }
    
    @objc private func VPNStatusDidChange(notification: Notification) {
        guard let connection = notification.object as? NETunnelProviderSession else {
            return
        }
        guard let _ = connection.manager.localizedDescription else {
            return
        }

        self.vpnStatus = connection.status.wrappedStatus
        print(self.vpnStatus)
    }
    
    // MARK: Priviate func
    private func turnOnTunnel(completionHandler: @escaping (Bool) -> Void) {
        let result = vpnManager.vpn.turnOnTunnel()
        SwiftyBeaver.info("turn on result : \(result.description)")
        completionHandler(result)
    }
    
    private func turnOffTunnel() {
        let result = vpnManager.vpn.turnOffTunnel()
        SwiftyBeaver.info("turn off result : \(result.description)")
    }
    
    private func setTransferredByteCount(inbound: Int, outbound: Int) {
        self.inbound = inbound
        self.outbound = outbound
    }
    
    /// 현재시간 - lastHandshakeTime 을 계산.
    private func calculateLastHandshakeTime(unixTime: Int) {
        let currentDate = Date()
        let unixDate = Date(timeIntervalSince1970: Double(unixTime))
        
        self.tunnelHandshakeTimestampAgo = Int(currentDate.timeIntervalSince(unixDate))
    }
}
