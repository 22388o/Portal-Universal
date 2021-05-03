//
//  CreateWalletNameView.swift
//  Portal
//
//  Created by Farid on 03.04.2021.
//

import SwiftUI
import Combine

struct CreateWalletNameView: View {
    @ObservedObject private var viewModel: CreateWalletScene.ViewModel
    
    init(viewModel: CreateWalletScene.ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Name your wallet")
                .font(.mainFont(size: 17))
                .foregroundColor(Color.createWalletLabel)
            
            Spacer().frame(height: 12)
            
            Text("We suggest using your name, or simple words like\n‘Personal’, ‘Work’, ‘Investments’ etc.")
                .multilineTextAlignment(.center)
                .font(.mainFont(size: 14))
                .foregroundColor(Color.coinViewRouteButtonActive)
            
            Spacer().frame(height: 27)
            
            HStack(spacing: 8) {
                WalletNameInputView(name: $viewModel.walletName)
                PButton(label: "Continue", width: 124, height: 48, fontSize: 15, enabled: viewModel.nameIsValid) {
                    withAnimation {
                        viewModel.walletCreationStep = .seed
                    }
                }
            }
            
            Divider()
                .frame(width: 410)
                .padding(.vertical, 30)
            
            Group {
                Image("lockedSafeIcon")
                    .offset(x: 1, y: -2)
                
                Spacer().frame(height: 24)
                
                Text("Let’s get you a wallet")
                    .font(.mainFont(size: 30))
                    .foregroundColor(Color.createWalletLabel)
                
                Spacer().frame(height: 17)
                
                Text("Create a universal wallet to store and trade all\nyour cryptocurrencies securely. You’ll be able to\ncreate more than one wallet.")
                    .multilineTextAlignment(.center)
                    .font(.mainFont(size: 16))
                    .foregroundColor(Color.coinViewRouteButtonActive).opacity(0.85)
            }
        }
    }
}

struct CreateWalletNameView_Previews: PreviewProvider {
    static var previews: some View {
        CreateWalletNameView(viewModel: CreateWalletScene.ViewModel(walletService: WalletsService()))
            .frame(width: 656, height: 656)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
