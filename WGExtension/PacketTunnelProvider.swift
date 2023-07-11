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
        let file = FileDestination()

        let url = try? FileManager.default.url(for: .documentDirectory,
                            in: .userDomainMask,
                            appropriateFor: nil,
                            create: true)

        let fileURL = url?.appendingPathComponent("LogByBeaver.log")
        file.logFileURL = fileURL
        SwiftyBeaver.self.addDestination(file)
        
        self.persistentTimer = RuntimeUpdater(timeInterval: 5) { [self] in
            self.wake()
        }
        SwiftyBeaver.verbose("TunnelProvider init() - PID : \(getpid())")
        self.persistentTimer?.startUpdating()
    }
    
    deinit {
        SwiftyBeaver.warning("Deinit 된다~~~")
        self.persistentTimer?.stopUpdating()
        self.persistentTimer = nil
    }

    func log(_ message: String) {
        NSLog("WireGuard Tunnel: %@\n", message)
    }

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        log("Starting tunnel")
        guard let protocolConfiguration = self.protocolConfiguration as? NETunnelProviderProtocol else {
            return
        }
        protocolConfiguration.serverAddress = wireGuard.endPoint
        guard let providerConfiguration = protocolConfiguration.providerConfiguration,
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
        case .getRuntimeLogs:
            self.getRuntimeLog { runtimeLog in
                completionHandler?(runtimeLog)  // 메인 앱으로 raw-string as runtimeLog 전달
            }
        case .getLog:
            self.sendAPI()
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
    
    private func getRuntimeLog(completionHandler: @escaping (Data?) -> Void) {
        adapter.getRuntimeConfiguration { settings in
            guard let settings = settings else {
                completionHandler(nil)
                return
            }
            completionHandler(settings.data(using: .utf8))
        }
    }
    
    private func sendAPI() {
        let urlString = "http://20.249.63.220:8000/" // API 엔드포인트 URL을 여기에 입력하세요.
        guard let url = URL(string: urlString) else {
            SwiftyBeaver.error("유효하지 않은 URL입니다.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // 요청 메서드를 원하는 것으로 변경하세요.
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                SwiftyBeaver.error("요청 실패: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                SwiftyBeaver.error("유효하지 않은 응답입니다.")
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let jsonResult = json as? [String: Any] {
                            if let result = jsonResult["result"] as? String {
                                SwiftyBeaver.info("응답 결과: \(result)")
                            }
                        }
                    } catch {
                        SwiftyBeaver.error("JSON 파싱 실패: \(error)")
                    }
                }
            } else {
                SwiftyBeaver.error("응답 상태 코드: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
}


/*  AllowedIPs 연결 해제 하지 않고도 바꿀 수 있는 방법..
 guard let tunnelConfiguration = try? TunnelConfiguration(fromWgQuickConfig: self.wgQuickConfig22!) else {
     return
 }

 self.adapter.update(tunnelConfiguration: tunnelConfiguration) { error in
     SwiftyBeaver.error(error?.localizedDescription ?? "")
 }
 */
