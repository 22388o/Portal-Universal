//
//  CreateWalletNameView.swift
//  Portal
//
//  Created by Farid on 03.04.2021.
//

import SwiftUI
import Combine

struct CreateWalletNameView: View {
    @ObservedObject private var viewModel: CreateWalletSceneViewModel
    
    init(viewModel: CreateWalletSceneViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                                
                Text("Let’s get you a wallet")
                    .font(.mainFont(size: 30))
                    .foregroundColor(Color.createWalletLabel)
                    .padding(.top, 24)
                
                Spacer().frame(height: 17)
                
                Text("Create a universal wallet to store and trade all\nyour cryptocurrencies securely. You’ll be able to\ncreate more than one wallet.")
                    .multilineTextAlignment(.center)
                    .font(.mainFont(size: 16))
                    .foregroundColor(Color.coinViewRouteButtonActive).opacity(0.85)
                
                Spacer().frame(height: 24)
                
                Text("Bitcoin address format")
                    .font(.mainFont(size: 14))
                
                Spacer().frame(height: 14)
                
                Picker("", selection: $viewModel.btcAddressFormat) {
                    ForEach(0 ..< BtcAddressFormat.allCases.count) { index in
                        Text(BtcAddressFormat.allCases[index].description).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 360)
                
                Spacer().frame(height: 14)
                
                Text("With SegWit addresses the network can process more transactions per block and the sender pays lower transaction fees.")
                    .multilineTextAlignment(.center)
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.coinViewRouteButtonActive).opacity(0.85)
                    .frame(width: 500)
            }
        }
    }
}

struct CreateWalletNameView_Previews: PreviewProvider {
    static var previews: some View {
        CreateWalletNameView(viewModel: CreateWalletSceneViewModel(type: .mnemonic(words: [], salt: "")))
            .frame(width: 656, height: 656)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
