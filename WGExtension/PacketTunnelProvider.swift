//
//  PacketTunnelProvider.swift
//  WGExtension
//
//  Original code from : https://github.com/roop/using-wireguardkit
//

import Darwin
import NetworkExtension
import WireGuardKit
import SwiftyBeaver

enum PacketTunnelProviderError: String, Error {
    case invalidProtocolConfiguration
    case cantParseWgQuickConfig
}

// TODO: VPN Status Notification
// TODO: Process를 죽이지 않고 [연결 해제 -> 재연결] 프로세스 구현
class PacketTunnelProvider: NEPacketTunnelProvider {
    // MARK: Private let
    private let appGroup = "AWR77X8V5R.group.example.chmun.WireGuardDemo"
    
    // MARK: Private var
    private var configuration: TunnelConfiguration?
    private var byteCount: TransferredByteCount?
    private var persistentTimer: RuntimeUpdaterProtocol?
    
    private lazy var adapter: WireGuardAdapter = {
        return WireGuardAdapter(with: self) { [weak self] _, message in
            self?.log(message)
        }
    }()
    
    // MARK: Public var
    public var wireGuard: WireGuard
    
    override init() {
        self.wireGuard = WireGuardBuilder(appGroup: appGroup)
        
        super.init()
        
        // SwiftyBeaver
        let platform = SBPlatformDestination(appID: "Ybnqk9",
                                             appSecret: "0uwcgsvlHm7t3xR3owHw7AWKlr9zRjln",
                                             encryptionKey: "byqgrigef1ym3aWroozlAkkNAm1nnCwf")

        SwiftyBeaver.addDestination(platform)
        
        self.persistentTimer = RuntimeUpdater(timeInterval: 5) { [self] in
            self.wake()
        }
        SwiftyBeaver.verbose("TunnelProvider init() - PID : \(getpid())")
        self.persistentTimer?.startUpdating()
        
        // set Notification
//        self.addNotification()
    }
    
    deinit {
        self.persistentTimer?.stopUpdating()
        self.persistentTimer = nil
    }

    func log(_ message: String) {
        NSLog("WireGuard Tunnel: %@\n", message)
    }

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        log("Starting tunnel")
        guard let protocolConfiguration = self.protocolConfiguration as? NETunnelProviderProtocol,
              let providerConfiguration = protocolConfiguration.providerConfiguration,
              let wgQuickConfig = providerConfiguration["wgQuickConfig"] as? String else {
            log("Invalid provider configuration")
            completionHandler(PacketTunnelProviderError.invalidProtocolConfiguration)
            return
        }

        guard let tunnelConfiguration = try? TunnelConfiguration(fromWgQuickConfig: wgQuickConfig) else {
            log("wg-quick config not parseable")
            completionHandler(PacketTunnelProviderError.cantParseWgQuickConfig)
            return
        }
        self.configuration = tunnelConfiguration

        adapter.start(tunnelConfiguration: tunnelConfiguration) { [weak self] adapterError in
            guard let self = self else { return }
            if let adapterError = adapterError {
                self.log("WireGuard adapter error: \(adapterError.localizedDescription)")
            } else {
                let interfaceName = self.adapter.interfaceName ?? "unknown"
                self.log("Tunnel interface is \(interfaceName)")
            }
            completionHandler(adapterError)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        log("Stopping tunnel")
        adapter.stop { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.log("Failed to stop WireGuard adapter: \(error.localizedDescription)")
            }
            completionHandler()

            #if os(macOS)
            // HACK: macOS의 버그 때문에, tunnel process를 강제로 종료시켜야만 한다.
            exit(0)
            #endif
        }
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        guard messageData.count == 1, let code = TunnelMessageCode(rawValue: messageData[0]) else {
            completionHandler?(nil)
            return
        }
        switch code {
        case .getTransferredByteCount:
            self.getTransferredByteCount { transferredByteCount in
                completionHandler?(transferredByteCount?.data)
                self.byteCount = transferredByteCount
            }
        case .startProcess:
            SwiftyBeaver.debug("Just started to process now! And My PID is : \(getpid())")
            completionHandler?(nil)
        default:
            return
        }
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
        SwiftyBeaver.info("Here is sleep(), PID is : \(getpid())")
    }

    override func wake() {
        // Add code here to wake up.
        SwiftyBeaver.info("Here is wake(), PID is : \(getpid())")
    }
    
    func getTransferredByteCount(completionHandler: @escaping (TransferredByteCount?) -> Void) {
        adapter.getRuntimeConfiguration { settings in
            guard let settings = settings,
                  let runtimeConfig = try? TunnelConfiguration(fromUapiConfig: settings, basedOn: self.configuration) else {
                completionHandler(nil)
                return
            }
            let rxBytesTotal = runtimeConfig.peers.reduce(0) { $0 + ($1.rxBytes ?? 0) }
            let txBytesTotal = runtimeConfig.peers.reduce(0) { $0 + ($1.txBytes ?? 0) }
            let transferredByteCount = TransferredByteCount(inbound: rxBytesTotal, outbound: txBytesTotal)
            completionHandler(transferredByteCount)
        }
    }

}
