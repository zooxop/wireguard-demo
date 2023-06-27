//
//  ContentViewModel.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import SwiftUI
import NetworkExtension

class ContentViewModel: ObservableObject {
    // MARK: - Properties
    @Published var interface: Interface
    @Published var peer: Peer
    @Published var isConnected: Bool = false
    @Published var inbound: Int = 0
    @Published var outbound: Int = 0
    
    private let appGroup = "AWX77X8V5R.group.example.chmun.WireGuardDemo"
    private let tunnelIdentifier = "example.chmun.WireGuardDemo.WGExtension"
    private let tunnelTitle = "WireGuard Demo App"
    
    private var tunnelManager: NETunnelProviderManager?
    private var runtimeUpdater: RuntimeUpdaterProtocol?
    
    // MARK: - Initializer
    init() {
        // 기본 Config 세팅
        let privateKey = UserDefaults.standard.string(forKey: UserDefaultsKey.interPrivateKey) ?? ""
        let address = UserDefaults.standard.string(forKey: UserDefaultsKey.interAddress) ?? ""
        let dns = UserDefaults.standard.string(forKey: UserDefaultsKey.interDNS) ?? "8.8.8.8"

        let publicKey = UserDefaults.standard.string(forKey: UserDefaultsKey.peerPublicKey) ?? ""
        let allowedIPs = UserDefaults.standard.string(forKey: UserDefaultsKey.peerAllowedIPs) ?? "0.0.0.0/0"
        let endpoint = UserDefaults.standard.string(forKey: UserDefaultsKey.peerEndpoint) ?? ""
        
        interface = Interface(privateKey: privateKey,
                              address: address,
                              dns: dns)
        peer = Peer(publicKey: publicKey,
                    allowedIPs: allowedIPs,
                    endPoint: endpoint)
        
        self.runtimeUpdater = RuntimeUpdater(timeInterval: 1) { [self] in
            getTransferredByteCount()
        }
    }
    
    deinit {
        self.runtimeUpdater = nil
        self.stopVpn()
    }
    
    func saveConfig() {
        UserDefaults.standard.set(interface.privateKey, forKey: UserDefaultsKey.interPrivateKey)
        UserDefaults.standard.set(interface.address, forKey: UserDefaultsKey.interAddress)
        UserDefaults.standard.set(interface.dns, forKey: UserDefaultsKey.interDNS)
        UserDefaults.standard.set(peer.publicKey, forKey: UserDefaultsKey.peerPublicKey)
        UserDefaults.standard.set(peer.allowedIPs, forKey: UserDefaultsKey.peerAllowedIPs)
        UserDefaults.standard.set(peer.endPoint, forKey: UserDefaultsKey.peerEndpoint)
    }
    
    func makeWgQuickConfig() -> String {
        return """
        [Interface]
        PrivateKey = \(interface.privateKey)
        Address = \(interface.address)
        DNS = \(interface.dns)

        [Peer]
        PublicKey = \(peer.publicKey)
        AllowedIPs = \(peer.allowedIPs)
        Endpoint = \(peer.endPoint)
        """
    }
    
    // MARK: - VPN
    
    /// start Tunneling
    func startVpn() {
        self.turnOnTunnel { isSuccess in
            if isSuccess {
                self.isConnected = isSuccess
                self.runtimeUpdater?.startUpdating()
            }
        }
    }
    
    /// stop Tunneling
    func stopVpn() {
        isConnected = false
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
            protocolConfiguration.serverAddress = self.peer.endPoint

            // wgQuickConfig 형식으로 config를 생성
            let wgQuickConfig = self.makeWgQuickConfig()

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
                        NSLog("Starting the tunnel")
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
                    NSLog("Stopping the tunnel")
                    session.stopTunnel()
                default:
                    break
                }
            }
        }
    }
}
