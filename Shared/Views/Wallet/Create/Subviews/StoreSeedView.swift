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

    Write the seed on paper (in that same order!), or save it to your 1Password or LastPass.




    Make 100% sure you have all the words, in that same order, and continue when you’re ready.
    """
        
    @ObservedObject private var viewModel: CreateWalletScene.ViewModel
    
    init(viewModel: CreateWalletScene.ViewModel) {
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
                        Text("Store the seed")
                            .font(.mainFont(size: 15))
                    }
                }
                
                Spacer().frame(height: 31)
                
                Text(description)
                    .font(.mainFont(size: 14))
                    .frame(width: 298)
                
                Spacer().frame(height: 10)
                
                PButton(label: "Next", width: 180, height: 48, fontSize: 15, enabled: true) {
                    withAnimation {
                        viewModel.walletCreationStep = .test
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
                        ForEach((1...viewModel.test.seed.count/2), id: \.self) {
                            Text("\($0)) \(viewModel.test.seed[$0 - 1])")
                        }
                    }
                    .frame(width: 150)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach((viewModel.test.seed.count/2 + 1...viewModel.test.seed.count), id: \.self) {
                            Text("\($0)) \(viewModel.test.seed[$0 - 1])")
                        }
                    }
                    .frame(width: 150)
                }
            }
        }
    }
}

struct StoreSeedView_Previews: PreviewProvider {
    static var previews: some View {
        StoreSeedView(viewModel: CreateWalletScene.ViewModel())
            .frame(width: 750, height: 656)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
