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
    // MARK: - Properties
    @Published var vpnManager: VPNManager
    @Published var isConnected: Bool = false
    @Published var inbound: Int = 0
    @Published var outbound: Int = 0
    
    public var wireGuard: WireGuard
    private let appGroup = "AWX77X8V5R.group.example.chmun.WireGuardDemo"
    private let tunnelIdentifier = "example.chmun.WireGuardDemo.WGExtension"
    private let tunnelTitle = "WireGuard Demo App"
    
    private var tunnelManager: NETunnelProviderManager?
    private var runtimeUpdater: RuntimeUpdaterProtocol?
    
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
    
    func startExtensionProcess() {
        guard let session: NETunnelProviderSession = tunnelManager?.connection as? NETunnelProviderSession else {
            return
        }
        do {
            // MARK: !!!! session.sendProviderMessage() 메서드만 호출시켜도, Extension 프로세스를 띄울 수 있다.
            try session.sendProviderMessage(TunnelMessageCode.startProcess.data) { responseData in
                print("캬캬캬캬")
            }
        } catch {
            print(error)
        }
    }
    
    private func turnOnTunnel(completionHandler: @escaping (Bool) -> Void) {
        guard let interface = wireGuard.interface,
              let peer = wireGuard.peer
        else {
            completionHandler(false)
            return
        }
        // `loadAllFromPreferences`를 통해 iOS(또는 macOS)의 환경설정 메뉴에 tunnel이 세팅되어 있는지 확인.
        NETunnelProviderManager.loadAllFromPreferences { tunnelManagersInSettings, error in
            if let error = error {
                NSLog("Error (loadAllFromPreferences): \(error)")
                completionHandler(false)
                return
            }

            // tunnel이 설치되어 있는 경우는 tunnel을 수정하고, 그렇지 않은 경우는 새로 생성하고 저장.
            // 설정 화면의 tunnel은 앱 하나당 0 또는 1개만 존재함.
            let preExistingTunnelManager = tunnelManagersInSettings?.first
            let tunnelManager = preExistingTunnelManager ?? NETunnelProviderManager()
            tunnelManager.localizedDescription = self.tunnelTitle  // Setting 화면에서 보이는 Tunnel의 Title

            // 사용자 지정 VPN 프로토콜 구성
            let protocolConfiguration = NETunnelProviderProtocol()

            // tunnel extension의 Bundle Identifier 설정
            protocolConfiguration.providerBundleIdentifier = self.tunnelIdentifier

            // Server 주소 설정. (non-nil)
            // Server의 domain명 또는 IP 주소
            protocolConfiguration.serverAddress = self.wireGuard.endPoint

            // wgQuickConfig 형식으로 config를 생성
            
            let builder = WireGuardConfigBuilder(interface: interface, peer: peer)
            guard let wgQuickConfig = builder.build() else {
                SwiftyBeaver.warning("make wgQuickConfig is failed")
                return
            }

            protocolConfiguration.providerConfiguration = [
                "wgQuickConfig": wgQuickConfig
            ]

            tunnelManager.protocolConfiguration = protocolConfiguration
            tunnelManager.isEnabled = true

            // tunnel 설정 저장.
            // 기존 터널을 수정하거나, 새로운 터널을 생성함.
            tunnelManager.saveToPreferences { error in
                if let error = error {
                    NSLog("Error (saveToPreferences): \(error)")
                    completionHandler(false)
                    return
                }
                // 유효한 인스턴스 확보를 위한 reloading
                tunnelManager.loadFromPreferences { error in
                    if let error = error {
                        NSLog("Error (loadFromPreferences): \(error)")
                        completionHandler(false)
                        return
                    }

                    // 이 시점에서 터널 구성 완료.
                    // 터널 시작 시도
                    do {
                        SwiftyBeaver.info("Starting the tunnel")
                        guard let session = tunnelManager.connection as? NETunnelProviderSession else {
                            fatalError("tunnelManager.connection is invalid")
                        }
                        try session.startTunnel()  // MARK: Start Tunneling
                    } catch {
                        NSLog("Error (startTunnel): \(error)")
                        completionHandler(false)
                    }
                    completionHandler(true)
                }
            }
            
            self.tunnelManager = tunnelManager
        }
    }
    
    private func turnOffTunnel() {
        NETunnelProviderManager.loadAllFromPreferences { tunnelManagersInSettings, error in
            if let error = error {
                NSLog("Error (loadAllFromPreferences): \(error)")
                return
            }
            if let tunnelManager = tunnelManagersInSettings?.first {
                guard let session = tunnelManager.connection as? NETunnelProviderSession else {
                    fatalError("tunnelManager.connection is invalid")
                }
                switch session.status {
                case .connected, .connecting, .reasserting:
                    SwiftyBeaver.info("Stopping the tunnel")
                    self.inbound = 0
                    self.outbound = 0
                    session.stopTunnel()
                default:
                    break
                }
            }
        }
    }
}
