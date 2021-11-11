//
//  StoreSeedView.swift
//  Portal
//
//  Created by Farid on 05.04.2021.
//

import SwiftUI

struct StoreSeedView: View {
    private let description = """
    See the 24 words on the right? It’s called a seed, and you’ll need it to access your wallet. If you lose it, you’ll lose the wallet and all the money in it. And we can’t restore it.

    
    Make 100% sure you have all the words, in that same order, and continue when you’re ready.
    """
        
    @ObservedObject private var viewModel: CreateWalletSceneViewModel
    
    init(viewModel: CreateWalletSceneViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(spacing: 55) {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Image("lockedSafeIcon")
                        .offset(y: -2)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Secure your wallet")
                            .font(.mainFont(size: 23))
                            .foregroundColor(.createWalletLabel)
                        Text("Store the seed")
                            .font(.mainFont(size: 15))
                            .foregroundColor(.coinViewRouteButtonInactive)
                    }
                }
                
                Spacer().frame(height: 31)
                
                Text(description)
                    .font(.mainFont(size: 14))
                    .foregroundColor(.coinViewRouteButtonActive)
                    .frame(width: 298)
                
                Spacer().frame(height: 60)
                
                HStack(spacing: 12) {
                    PButton(label: "Next", width: 140, height: 40, fontSize: 15, enabled: true) {
                        withAnimation {
                            viewModel.walletCreationStep = .test
                        }
                    }
                    .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                    
                    Text("Copy to clipboard")
                        .underline()
                        .foregroundColor(Color.txListTxType)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.copyToClipboard()
                        }
                }
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.seedBoxBackground)
                    .frame(width: 319, height: 428)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.seedBoxBorder, lineWidth: 1)
                    )
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach((1...viewModel.test.seed.count/2), id: \.self) { index in
                            HStack {
                                Text("\(index))")
                                    .foregroundColor(.blush)
                                Text("\(viewModel.test.seed[index - 1])")
                                    .foregroundColor(.brownishOrange)
                            }
                        }
                    }
                    .frame(width: 150)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach((viewModel.test.seed.count/2 + 1...viewModel.test.seed.count), id: \.self) { index in
                            HStack {
                                Text("\(index))")
                                    .foregroundColor(.blush)
                                Text("\(viewModel.test.seed[index - 1])")
                                    .foregroundColor(.brownishOrange)
                            }
                        }
                    }
                    .frame(width: 150)
                }
            }
        }
        .frame(minWidth: 650)
        .frame(minHeight: 550)
    }
}

struct StoreSeedView_Previews: PreviewProvider {
    static var previews: some View {
        StoreSeedView(viewModel: CreateWalletSceneViewModel(type: .mnemonic(words: [], salt: String())))
            .frame(width: 750, height: 656)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
