//
//  RestoreWalletView.swift
//  Portal
//
//  Created by Farid on 09.05.2021.
//

import SwiftUI

struct RestoreWalletView: View {
    @ObservedObject var viewModel: RestoreWalletViewModel
    private var accountManager = Portal.shared.accountManager
    @ObservedObject private var state = Portal.shared.state
    
    init() {
        viewModel = .init()
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            Color.portalWalletBackground
            
            HStack(spacing: 12) {
                Group {
                    Text("Welcome to Portal")
                        .font(.mainFont(size: 14, bold: true))
                    Group {
                        Text("|")
                        Text("Restore wallet")
                    }
                    .font(.mainFont(size: 14))
                }
                .foregroundColor(.white)
            }
            .padding(.top, 35)
            
            if accountManager.activeAccount != nil {
                HStack {
                    PButton(label: "Go back", width: 80, height: 30, fontSize: 12, enabled: true) {
                        withAnimation {
                            state.current = .currentAccount
                        }
                    }
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.leading, 30)
            }
            
            ZStack {
                Color.black.opacity(0.58)
                
                Color.white.cornerRadius(5).padding(8)
                                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 14) {
                        Image("lockedSafeIcon")
                            .offset(y: -2)
                        Text("Restore Wallet")
                            .font(.mainFont(size: 23))
                            .foregroundColor(Color.lightActiveLabel)
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Acount name")
                                .font(.mainFont(size: 18))
                            PTextField(text: $viewModel.accountName, placeholder: "Enter account name", upperCase: true, width: 360, height: 40)
                        }
                        VStack(alignment: .leading, spacing: 7) {
                            Text("BTC address format")
                                .font(.mainFont(size: 18))
                            Picker("", selection: $viewModel.btcAddressFormat) {
                                ForEach(0 ..< BtcAddressFormat.allCases.count) { index in
                                    Text(BtcAddressFormat.allCases[index].description).tag(index)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .frame(width: 360, height: 40)
                    }
                    .foregroundColor(Color.lightActiveLabel)
                    .padding(.top, 20)
                    
                    Text("Seed")
                        .font(.mainFont(size: 18))
                        .padding(.top, 13)
                        .padding(.bottom, 10)
                    
                    VStack {
                        ForEach(0...5, id: \.self) { row in
                            HStack {
                                ForEach(1...4, id: \.self)  { index in
                                    RestoreSeedField(text: $viewModel.seed[(row * 4 + index) - 1], index: row * 4 + index)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        PButton(bgColor: Color(red: 250/255, green: 147/255, blue: 36/255), label: "Restore", width: 203, height: 48, fontSize: 15, enabled: viewModel.restoreReady) {
                            withAnimation {
                                accountManager.save(account: viewModel.account)
                            }
                        }
                        
                        if !viewModel.restoreReady {
                            HStack {
                                Image(systemName: "exclamationmark.circle").font(.system(size: 16, weight: .regular))
                                Text(viewModel.errorMessage)
                                    .font(.mainFont(size: 14))
                            }
                            .foregroundColor(Color(red: 250/255, green: 147/255, blue: 36/255))
                            .padding()
                        } else {
                            EmptyView()
                        }
                        
                        Spacer()
                        
                        PButton(label: "Create new wallet", width: 140, height: 30, fontSize: 12, enabled: true) {
                            withAnimation {
                                state.current = .createAccount
                            }
                        }
                    }
                    .frame(width: 725)
                    .padding(.top, 20)
                }
            }
            .cornerRadius(8)
            .padding(EdgeInsets(top: 88, leading: 24, bottom: 24, trailing: 24))
        }
    }
}

struct RestoreWalletView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreWalletView()
            .iPadLandscapePreviews()
    }
}
