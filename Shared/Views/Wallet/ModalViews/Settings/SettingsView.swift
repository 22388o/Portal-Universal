//
//  SettingsView.swift
//  Portal
//
//  Created by Farid on 29.10.2021.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var viewModel: AccountSettingsViewModel
    
    @State private var portfolioIncludesExchangeBalance = false
    @State private var showPasscodeSettings = false
    
    private var settingsWidth: CGFloat {
        #if os(iOS)
            return 300
        #else
            return 280
        #endif
    }
    
    init() {
        self.viewModel = AccountSettingsViewModel.config()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.94))
                .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 0)
            
            
            if showPasscodeSettings {
                PasscodeSettings(showPasscodeSettings: $showPasscodeSettings)
            } else {
                VStack(spacing: 0) {
                    GeneralSettingsView(showPasscodeSettings: $showPasscodeSettings)
                    
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
                            Spacer()
                            Text("\(viewModel.confirmationThreshold)")
                                .font(.mainFont(size: 14))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    Toggle("Portfolio includes exchange balances:", isOn: $portfolioIncludesExchangeBalance)
                        .toggleStyle(SwitchToggleStyle())
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.lightActiveLabel)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
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
                    }
                    .frame(height: 45)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    Spacer()
                    
                    PButton(label: "Apply", width: 80, height: 30, fontSize: 12, enabled: viewModel.canApplyChanges) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.applySettings()
                            Portal.shared.state.modalView = .none
                        }
                    }
                    .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                    .padding()
                }
            }
        }
        .frame(width: settingsWidth, height: 440)
    }
}

struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
