//
//  TokenSelector.swift
//  Portal
//
//  Created by Farid on 11.04.2021.
//

import SwiftUI

struct TokenSelector: View {
    let tokens: [Erc20Token]
    @Binding var selectedToken: Erc20Token
        
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .frame(width: 120, height: 40)
                .foregroundColor(Color.white.opacity(0.1))
        }
        .overlay(
            Menu {
                ForEach(tokens, id: \.contractAddress) { token in
                    Button("\(token.symbol) \(token.name)") {
                        selectedToken = token
                    }
                }
            } label: {
                HStack {
                    Text(selectedToken.symbol)
                        .font(.mainFont(size: 15))
                        .foregroundColor(Color.white.opacity(0.8))
                    CoinImageView(size: 24, url: selectedToken.iconURL)
                }
            }
        )
    }
}

struct TokenSelector_Previews: PreviewProvider {
    static var previews: some View {
        TokenSelector(tokens: [], selectedToken: .constant(.MATIC))
            .frame(width: 120, height: 48)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .background(
                ZStack {
                    Color.portalWalletBackground
                    Color.black.opacity(0.58)
                }
            )
    }
}