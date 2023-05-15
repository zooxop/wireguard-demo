//
//  ContentView.swift
//  WireGuardDemo
//
//  Created by 문철현 on 2023/05/09.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ContentViewModel = ContentViewModel()
    @State var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                propertyBox("[Interface]") {
                    boxTextFieldItem("Private Key", text: $viewModel.interface.privateKey)
                    boxTextFieldItem("Address", text: $viewModel.interface.address)
                    boxTextFieldItem("DNS", text: $viewModel.interface.dns)
                }
                
                propertyBox("[Peer]") {
                    boxTextFieldItem("Public Key", text: $viewModel.peer.publicKey)
                    boxTextFieldItem("AllowedIPs", text: $viewModel.peer.allowedIPs)
                    boxTextFieldItem("Endpoint", text: $viewModel.peer.endPoint)
                }
                
                HStack {
                    Button("Save") {
                        viewModel.saveConfig()
                        showAlert.toggle()
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
                    Text("received : \(viewModel.received) / sent : \(viewModel.sent)")
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
