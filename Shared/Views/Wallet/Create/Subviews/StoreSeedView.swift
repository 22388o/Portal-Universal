//
//  StoreSeedView.swift
//  Portal
//
//  Created by Farid on 05.04.2021.
//

import SwiftUI

struct StoreSeedView: View {
    private let description24 = """
    See the 24 words on the right? It’s called a seed, and you’ll need it to access your wallet. If you lose it, you’ll lose the wallet and all the money in it. And we can’t restore it.
    
    
    Make 100% sure you have all the words, in that same order, and continue when you’re ready.
    """
    
    private let description12 = """
    See the 12 words on the right? It’s called a seed, and you’ll need it to access your wallet. If you lose it, you’ll lose the wallet and all the money in it. And we can’t restore it.
    
    
    Make 100% sure you have all the words, in that same order, and continue when you’re ready.
    """
    
    @ObservedObject private var viewModel: CreateAccountViewModel
    
    init(viewModel: CreateAccountViewModel) {
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
                
                Text(viewModel.isUsingStrongSeed ? description24 : description12)
                    .font(.mainFont(size: 14))
                    .foregroundColor(.coinViewRouteButtonActive)
                    .frame(width: 298)
                
                Spacer().frame(height: 60)
                
                HStack(spacing: 12) {
                    PButton(label: "Next", width: 180, height: 48, fontSize: 15, enabled: true) {
                        withAnimation {
                            viewModel.step = .test
                        }
                    }
                    .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                    
                    Text(viewModel.copiedToClipboard ? "Copied to clipboard!" : "Copy to clipboard")
                        .frame(width: 130)
                        .foregroundColor(viewModel.copiedToClipboard ? Color.green : Color.txListTxType)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.copyToClipboard()
                        }
                }
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.seedBoxBackground)
                    .frame(width: 319, height: 448)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.seedBoxBorder, lineWidth: 1)
                    )
                
                VStack(spacing: 0) {
                    Toggle("24 words seed", isOn: $viewModel.isUsingStrongSeed)
                        .frame(width: 150)
                        .font(.mainFont(size: 10))
                        .foregroundColor(Color.coinViewRouteButtonInactive)
                        .toggleStyle(SwitchToggleStyle())
                        .padding(.bottom)
                    
                    HStack(spacing: 0) {
                        if viewModel.isUsingStrongSeed {
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
                        } else {
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
                        }
                    }
                }
            }
        }
        .frame(minWidth: 650)
        .frame(minHeight: 550)
    }
}

struct StoreSeedView_Previews: PreviewProvider {
    static var previews: some View {
        StoreSeedView(viewModel: CreateAccountViewModel(type: .mnemonic(words: [], salt: String())))
            .frame(width: 750, height: 656)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
