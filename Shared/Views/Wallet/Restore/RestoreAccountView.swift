//
//  RestoreAccountView.swift
//  Portal
//
//  Created by Farid on 09.05.2021.
//

import SwiftUI

struct RestoreAccountView: View {
    @ObservedObject var viewModel: RestoreAccountViewModel
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
                        Text("Restore account")
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
                            state.rootView = .account
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
                        Text("Restore Account")
                            .font(.mainFont(size: 23))
                            .foregroundColor(Color.lightActiveLabel)
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Acount name")
                                .font(.mainFont(size: 18))
                            PTextField(text: $viewModel.accountName, placeholder: "Enter account name", upperCase: true, width: 360, height: 40)
                        }
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
                            state.loading = true
                            DispatchQueue.global(qos: .userInitiated).async {
                                accountManager.save(account: viewModel.account)
                            }
                        }
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                        
                        if !viewModel.restoreReady {
                            HStack {
                                Image("exclamationmark.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text(viewModel.errorMessage)
                                    .font(.mainFont(size: 14))
                            }
                            .foregroundColor(Color(red: 250/255, green: 147/255, blue: 36/255))
                            .padding()
                        } else {
                            EmptyView()
                        }
                        
                        Spacer()
                        
                        PButton(label: "Create new account", width: 140, height: 30, fontSize: 12, enabled: true) {
                            withAnimation {
                                state.rootView = .createAccount
                            }
                        }
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                    }
                    .frame(width: 725)
                    .padding(.top, 20)
                }
            }
            .cornerRadius(8)
            .padding(EdgeInsets(top: 88, leading: 24, bottom: 24, trailing: 24))
        }
        .frame(minWidth: 850)
        .frame(minHeight: 700)
    }
}

struct RestoreAccountView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreAccountView()
            .iPadLandscapePreviews()
    }
}
