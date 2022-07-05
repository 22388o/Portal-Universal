//
//  AccountNameView.swift
//  Portal
//
//  Created by Farid on 03.04.2021.
//

import SwiftUI
import Combine

struct AccountNameView: View {
    @Binding var scene: PortalState.Scene
    @ObservedObject var viewModel: CreateAccountViewModel
        
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("Name your account")
                .font(.mainFont(size: 17))
                .foregroundColor(Color.createWalletLabel)
            
            Spacer().frame(height: 12)
            
            Text("We suggest using your name, or simple words like\n‘Personal’, ‘Work’, ‘Investments’ etc.")
                .multilineTextAlignment(.center)
                .font(.mainFont(size: 14))
                .foregroundColor(Color.coinViewRouteButtonActive)
            
            Spacer().frame(height: 27)
            
            HStack(spacing: 8) {
                AccountNameInputView(name: $viewModel.accountName)
                PButton(label: "Continue", width: 124, height: 48, fontSize: 15, enabled: viewModel.nameIsValid) {
                    withAnimation {
                        viewModel.step = .seed
                    }
                }
                .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
            }
            
            Divider()
                .frame(width: 410)
                .padding(.vertical, 30)
            
            Group {
                Image("lockedSafeIcon")
                    .offset(x: 1, y: -2)
                                
                Text("Let’s get you a wallet")
                    .font(.mainFont(size: 30))
                    .foregroundColor(Color.createWalletLabel)
                    .padding(.top, 24)
                
                Spacer().frame(height: 17)
                
                Text("Create a universal wallet to store and trade all\nyour cryptocurrencies securely. You’ll be able to\ncreate more than one wallet.")
                    .multilineTextAlignment(.center)
                    .font(.mainFont(size: 16))
                    .foregroundColor(Color.coinViewRouteButtonActive).opacity(0.85)
                
                Spacer().frame(height: 17)
                
                HStack {
                    Text("Already have a wallet?")
                        .foregroundColor(Color.coinViewRouteButtonActive).opacity(0.85)
                    
                    Text("Restore it")
                        .underline()
                        .foregroundColor(Color.txListTxType)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            scene = .restoreAccount
                        }
                }
                .font(.mainFont(size: 16))

                
                Spacer()
            }
        }
        #if os(macOS)
        .frame(minWidth: 400)
        .frame(minHeight: 600)
        #endif
    }
}

struct CreateWalletNameView_Previews: PreviewProvider {
    static var previews: some View {
        AccountNameView(scene: .constant(.createAccount), viewModel: CreateAccountViewModel(type: .mnemonic(words: [], salt: "")))
            .frame(width: 656, height: 656)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
