//
//  AccountSettingsView.swift
//  Portal
//
//  Created by Farid on 29.10.2021.
//

import SwiftUI
 
struct AccountSettingsView: View {
    @ObservedObject private var viewModel: AccountSettingsViewModel
    
    init() {
        self.viewModel = AccountSettingsViewModel.config()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.94))
                .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 2)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Account settings")
                        .font(.mainFont(size: 12, bold: true))
                        .foregroundColor(Color.walletsLabel)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 9)
                    Spacer()
                }
                
                Divider()
                
                Stepper(value: $viewModel.confirmationThreshold, in: 0...8) {
                    HStack {
                        Text("Tx confirmation threshold:")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.lightActiveLabel)
                        Text("\(viewModel.confirmationThreshold)")
                            .font(.mainFont(size: 14))
                    }
                }
                .padding([.top, .horizontal])
                
                Group {
                    VStack(spacing: 6) {
                        HStack {
                            Text("Bitcoin network:")
                                .font(.mainFont(size: 12)).foregroundColor(Color.lightActiveLabel)
                            Spacer()
                        }
                        
                        BtcNetworkPicker(btcNetwork: $viewModel.btcNetwork)
                    }
                                    
                    VStack(spacing: 6) {
                        HStack {
                            Text("Ethereum network:")
                                .font(.mainFont(size: 12)).foregroundColor(Color.lightActiveLabel)
                            Spacer()
                        }
                        
                        EthNetworkPicker(ethNetwork: $viewModel.ethNetwork, description: viewModel.ethNetworkString)
                    }
                    
                    VStack(spacing: 6) {
                        HStack {
                            Text("Infura API key:")
                                .font(.mainFont(size: 12)).foregroundColor(Color.lightActiveLabel)
                            Spacer()
                        }
                        
                        TextField("Key", text: $viewModel.infuraKeyString)
                    }
                }
                .frame(height: 45)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                Spacer()
                
                PButton(label: "Apply", width: 80, height: 30, fontSize: 12, enabled: viewModel.canApplyChanges) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.applySettings()
                        Portal.shared.state.accountSettings.toggle()
                    }
                }
                .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                .padding()
            }
        }
        .frame(width: settingsWidth, height: 333)
        .transition(.move(edge: .leading))
    }
    
    private var settingsWidth: CGFloat {
        #if os(iOS)
        300
        #else
        216
        #endif
    }
}

struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView()
    }
}
