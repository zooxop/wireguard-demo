//
//  ContentView.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ContentViewModel = ContentViewModel()
    
    private var inbound: String {
        return
            convertBytes(bytes: Double(viewModel.inbound)) + " " +
            getUnit(bytes: viewModel.inbound)
    }
    
    private var outbound: String {
        return
            convertBytes(bytes: Double(viewModel.outbound)) + " " +
            getUnit(bytes: viewModel.outbound)
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                propertyBox("[Interface]") {
                    boxTextFieldItem("Private Key", text: $viewModel.vpnManager.privateKey)
                    boxTextFieldItem("Address", text: $viewModel.vpnManager.address)
                    boxTextFieldItem("DNS", text: $viewModel.vpnManager.dns)
                }
                
                propertyBox("[Peer]") {
                    boxTextFieldItem("Public Key", text: $viewModel.vpnManager.publicKey)
                    boxTextFieldItem("AllowedIPs", text: $viewModel.vpnManager.allowedIPs)
                    boxTextFieldItem("Endpoint", text: $viewModel.vpnManager.endPoint)
                }
                
                HStack {
                    Button {
                        viewModel.getTransferredByteCount()
                    } label: {
                        Text("Refresh Bytes")
                    }
                    
                    Spacer()
                    
                    Button {
                        if viewModel.isConnected == false {
                            viewModel.startVpn()
                        } else if viewModel.isConnected == true {
                            viewModel.stopVpn()
                        }
                    } label: {
                        Text(viewModel.isConnected ? "Deactivate" : "Activate")
                            .foregroundColor(viewModel.isConnected ? .blue : .red)
                    }
                }
                
                if viewModel.isConnected {
                    withAnimation {
                        HStack {
                            Spacer()
                            Text("Send : \(self.outbound)\nReceive : \(self.inbound)")
                        }
                    }
                }
                
                Button("Start process") {
                    viewModel.startExtensionProcess()
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
    }
    
    private func propertyBox<Content: View>(_ title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack {
            boxTitle(title)
            
            Divider()
            
            content()
        }
        .padding(5)
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.gray, lineWidth: 0.6)
        )
    }
    
    @ViewBuilder
    private func boxTitle(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.title3)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func boxTextFieldItem(_ caption: String, text: Binding<String>) -> some View {
        HStack {
            VStack(alignment: .trailing) {
                Text(caption)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                TextField(caption, text: text)
                    
            }
            .frame(maxWidth: WindowSize.fixedSize.width - 120)
        }
    }
    
    private func convertBytes(bytes: Double) -> String {
        let kb = 1024.0
        let mb = kb * kb
        let gb = mb * kb

        if bytes >= gb {
            return String(format: "%.2f", bytes/gb)
        } else if bytes >= mb {
            return String(format: "%.2f", bytes/mb)
        } else if bytes >= kb {
            return String(format: "%.2f", bytes/kb)
        } else {
            return "\(Int(bytes))"
        }
    }
    
    private func getUnit(bytes: Int) -> String {
        switch bytes {
        case 0..<1_024:
            return "Byte"
        case 1_024..<(1_024 * 1_024):
            return "KB"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "MB"
        case (1_024 * 1_024 * 1_024)...Int.max:
            return "GB"
        default:
            return "Byte"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(minWidth: WindowSize.fixedSize.width, minHeight: WindowSize.fixedSize.height)
            .frame(maxWidth: WindowSize.fixedSize.width, maxHeight: WindowSize.fixedSize.height)
    }
}
