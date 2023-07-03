//
//  VPN.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/06/28.
//

import Foundation
import NetworkExtension
import SwiftyBeaver

public protocol VPN: AnyObject {
    var tunnelTitle: String { get }
    var tunnelIdentifier: String { get }
    var endPoint: String { get }
    var interface: Interface? { get set }
    var peer: Peer? { get set }
    
    var tunnelManager: NETunnelProviderManager? { get set }
}

extension VPN {
    /// install VPN Interface at [환경설정>네트워크]
    public func install(completion: @escaping (Bool) -> Void) {
        guard let interface = interface,
              let peer = peer
        else {
            SwiftyBeaver.warning("Either the Interface or the Peer is nil.")
            completion(false)
            return
        }
        // `loadAllFromPreferences`를 통해 iOS(또는 macOS)의 환경설정 메뉴에 tunnel이 세팅되어 있는지 확인.
        NETunnelProviderManager.loadAllFromPreferences { tunnelManagersInSettings, error in
            if let error = error {
                SwiftyBeaver.error("Error (loadAllFromPreferences): \(error)")
                completion(false)
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
            protocolConfiguration.serverAddress = self.endPoint

            // wgQuickConfig 형식으로 config를 생성
            
            let builder = WireGuardConfigBuilder(interface: interface, peer: peer)
            guard let wgQuickConfig = builder.build(keepAlive: 25) else {
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
                    completion(false)
                }
                completion(true)
            }
            self.tunnelManager = tunnelManager
        }
    }
    
    /// Start up to VPN(Network Extension) Process
    public func prepare() {
        guard let session: NETunnelProviderSession = tunnelManager?.connection as? NETunnelProviderSession else {
            SwiftyBeaver.error("NETunnelProviderManager object is nil")
            return
        }
        do {
            // MARK: !!!! session.sendProviderMessage() 메서드만 호출시켜도, Extension 프로세스를 띄울 수 있다.
            try session.sendProviderMessage(TunnelMessageCode.startProcess.data) { responseData in
                if let responseData = responseData {
                    SwiftyBeaver.info("VPN Process is started. \(String(data: responseData, encoding: .utf8) ?? "")")
                }
            }
        } catch {
            print(error)
        }
    }
}

extension VPN {
    /// start VPN
    public func turnOnTunnel() -> Bool {
        // 터널 시작 시도
        guard let tunnelManager = self.tunnelManager else {
            return false
        }
        do {
            SwiftyBeaver.info("Starting the tunnel")
            guard let session = tunnelManager.connection as? NETunnelProviderSession else {
                fatalError("tunnelManager.connection is invalid")
            }
            try session.startTunnel()  // MARK: Start Tunneling
            return true
        } catch {
            SwiftyBeaver.error("Error (startTunnel): \(error)")
            return false
        }
    }
    
    /// stop VPN
    public func turnOffTunnel() -> Bool {
        // 터널 중지
        guard let tunnelManager = self.tunnelManager else {
            return false
        }
        guard let session = tunnelManager.connection as? NETunnelProviderSession else {
            SwiftyBeaver.error("tunnelManager.connection is invalid")
            return false
        }
        switch session.status {
        case .connected, .connecting, .reasserting:
            SwiftyBeaver.info("Stopping the tunnel")
            session.stopTunnel()
            return true
        default:
            break
        }
        
        return false
    }
}

extension VPN {
    /// Communicate with a tunnel through `handleAppMessage` in PacketTunnelProvider
    func handleAppMessage(code: TunnelMessageCode, completion: @escaping (Data?) -> Void) {
        guard let session: NETunnelProviderSession = tunnelManager?.connection as? NETunnelProviderSession else {
            completion(nil)
            return
        }
        do {
            try session.sendProviderMessage(code.data) { responseData in
                guard let responseData = responseData else {
                    completion(nil)
                    return
                }
                completion(responseData)
            }
        } catch {
            print(error)
        }
    }
}
