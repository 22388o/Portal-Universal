//
//  SeedTestView.swift
//  Portal
//
//  Created by Farid on 06.04.2021.
//

import SwiftUI

struct SeedTestView: View {
    private let horizontalSeedTestRange: ClosedRange<Int> = 0...2
    private let verticalSeedTestRange: ClosedRange<Int> = 1...4
    
    private var accountManager = Portal.shared.accountManager
    
    @ObservedObject private var viewModel: CreateAccountViewModel
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
            
            Text("Let’s see if you wrote the seed correctly ...")
                .font(.mainFont(size: 14))
                .foregroundColor(.createWalletLabel)
                .multilineTextAlignment(.center)
                .padding()
            
            if viewModel.test.selectedWords.count < viewModel.test.testIndices.count {
                let index = viewModel.test.testIndices[viewModel.test.selectedWords.count]
                let indexString = viewModel.formattedIndexString(index)
                
                Text("Select \(indexString) from your seed")
                    .font(.mainFont(size: 14))
                    .foregroundColor(.createWalletLabel)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }
            
            ForEach(horizontalSeedTestRange, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(verticalSeedTestRange, id: \.self)  { index in
                        SeedTestWordView(
                            word: viewModel.test.testArray[(row * 4 + index) - 1],
                            testWords: $viewModel.test.selectedWords
                        )
                    }
                }
            }
            .disabled(viewModel.test.formIsValid)
            
            if viewModel.test.formIsValid {
                Text("Correct! You’re ready to create your wallet.")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color(red: 250/255, green: 147/255, blue: 36/255))
                    .padding()
            } else {
                Text("Your wallet will be ready when words are selected in correct order.")
                    .font(.mainFont(size: 14))
                    .foregroundColor(.createWalletLabel)
                    .padding()
            }

            PButton(bgColor: Color(red: 250/255, green: 147/255, blue: 36/255), label: "Create my account", width: 203, height: 48, fontSize: 15, enabled: viewModel.test.formIsValid) {
                withAnimation {
                    state.loading = true
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    accountManager.save(account: viewModel.account)
                }
            }
            .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
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
