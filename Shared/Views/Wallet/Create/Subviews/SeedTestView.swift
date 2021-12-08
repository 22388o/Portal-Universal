//
//  SeedTestView.swift
//  Portal
//
//  Created by Farid on 06.04.2021.
//

import SwiftUI

struct SeedTestView: View {
    @ObservedObject private var viewModel: CreateAccountViewModel
    private var accountManager = Portal.shared.accountManager
    @ObservedObject private var state = Portal.shared.state

    init(viewModel: CreateAccountViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Image("lockedSafeIcon")
            
            Text("Confirm the seed")
                .font(.mainFont(size: 24))
                .foregroundColor(.createWalletLabel)
                .padding(.top, 30)
                .padding(.bottom, 13)
            
            Text("Let’s see if you wrote the seed correctly ... \nenter the following words from your seed.")
                .font(.mainFont(size: 14))
                .foregroundColor(.createWalletLabel)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 0) {
                HStack(spacing: 26) {
                    VStack(alignment: .leading, spacing: 9) {
                        Text(viewModel.formattedIndexString(viewModel.test.testIndices[0]))
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString1, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                        Text(viewModel.formattedIndexString(viewModel.test.testIndices[1]))
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString2, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                    }
                    .foregroundColor(.createWalletLabel)
                    
                    VStack(alignment: .leading, spacing: 9) {
                        Text(viewModel.formattedIndexString(viewModel.test.testIndices[2]))
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString3, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                        Text(viewModel.formattedIndexString(viewModel.test.testIndices[3]))
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString4, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                    }
                    .foregroundColor(.createWalletLabel)
                }
                .padding(.top, 25)
                .padding(.bottom, 30)
                
                if viewModel.test.formIsValid {
                    Text("Correct! You’re ready to create your wallet.")
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color(red: 250/255, green: 147/255, blue: 36/255))
                } else {
                    Text("Your wallet will be ready when words are correct.")
                        .font(.mainFont(size: 14))
                        .foregroundColor(.createWalletLabel)
                }
                
                Spacer().frame(height: 21)
                
                PButton(bgColor: Color(red: 250/255, green: 147/255, blue: 36/255), label: "Create my wallet", width: 203, height: 48, fontSize: 15, enabled: viewModel.test.formIsValid) {
                    withAnimation {
                        state.loading = true
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        accountManager.save(account: viewModel.account)
                    }
                }
                .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
            }
        }
        .frame(minWidth: 600)
        .frame(minHeight: 550)
    }
}

struct SeedTestView_Previews: PreviewProvider {
    static var previews: some View {
        SeedTestView(viewModel: CreateAccountViewModel(type: .mnemonic(words: [], salt: String())))
            .frame(width: 750, height: 656)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
