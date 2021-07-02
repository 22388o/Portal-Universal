//
//  SeedTestView.swift
//  Portal
//
//  Created by Farid on 06.04.2021.
//

import SwiftUI

struct SeedTestView: View {
    @ObservedObject private var viewModel: CreateWalletSceneViewModel
    @EnvironmentObject private var service: WalletsService
    @StateObject private var keyboard = KeyboardResponder()

    init(viewModel: CreateWalletSceneViewModel) {
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
            
            Text("Let’s see if you wrote the seed correctly:\nenter the following words from your seed.")
                .font(.mainFont(size: 14))
                .foregroundColor(.createWalletLabel)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 0) {
                HStack(spacing: 26) {
                    VStack(alignment: .leading, spacing: 9) {
                        Text("\(viewModel.test.testIndices[0])) word")
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString1, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                        Text("\(viewModel.test.testIndices[1])) word")
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString2, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                    }
                    .foregroundColor(.createWalletLabel)
                    
                    VStack(alignment: .leading, spacing: 9) {
                        Text("\(viewModel.test.testIndices[2])) word")
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString3, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                        Text("\(viewModel.test.testIndices[3])) word")
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
                        service.createWallet(model: viewModel.newWalletViewModel)
                    }
                }
            }
            .padding(.bottom, keyboard.currentHeight)
        }
    }
}

struct SeedTestView_Previews: PreviewProvider {
    static var previews: some View {
        SeedTestView(viewModel: CreateWalletSceneViewModel())
            .frame(width: 750, height: 656)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
