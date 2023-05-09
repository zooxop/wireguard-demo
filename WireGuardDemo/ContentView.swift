//
//  ContentView.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import SwiftUI

struct ContentView: View {
    @State var interface: Interface
    @State var peer: Peer
    @State var showAlert: Bool = false
    
    init() {
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
    }
    
    private func saveConfig() {
        UserDefaults.standard.set(interface.privateKey, forKey: UserDefaultsKey.interPrivateKey)
        UserDefaults.standard.set(interface.address, forKey: UserDefaultsKey.interAddress)
        UserDefaults.standard.set(interface.dns, forKey: UserDefaultsKey.interDNS)
        UserDefaults.standard.set(peer.publicKey, forKey: UserDefaultsKey.peerPublicKey)
        UserDefaults.standard.set(peer.allowedIPs, forKey: UserDefaultsKey.peerAllowedIPs)
        UserDefaults.standard.set(peer.endPoint, forKey: UserDefaultsKey.peerEndpoint)
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                propertyBox("[Interface]") {
                    boxTextFieldItem("Private Key", text: $interface.privateKey)
                    boxTextFieldItem("Address", text: $interface.address)
                    boxTextFieldItem("DNS", text: $interface.dns)
                }
                
                propertyBox("[Peer]") {
                    boxTextFieldItem("Public Key", text: $peer.publicKey)
                    boxTextFieldItem("AllowedIPs", text: $peer.allowedIPs)
                    boxTextFieldItem("Endpoint", text: $peer.endPoint)
                }
                
                HStack {
                    Button("Save") {
                        saveConfig()
                        showAlert.toggle()
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Activate")  // Deactivate
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Save"), message: Text("Save successful"))
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(minWidth: WindowSize.fixedSize.width, minHeight: WindowSize.fixedSize.height)
            .frame(maxWidth: WindowSize.fixedSize.width, maxHeight: WindowSize.fixedSize.height)
    }
}
