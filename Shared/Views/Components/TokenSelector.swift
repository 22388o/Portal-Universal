//
//  FiatCurrencyButton.swift
//  Portal
//
//  Created by Farid on 11.04.2021.
//

import SwiftUI

struct TokenSelector: View {
    let currencies: [Erc20Token]
    @Binding var selectedCurrrency: Erc20Token
        
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.94))
                .opacity(0.14)
        }
        .overlay(
            Menu {
                ForEach(currencies, id: \.contractAddress) { currency in
                    Button("\(currency.symbol) \(currency.name)") {
                        selectedCurrrency = currency
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 24, height: 24)
                        Text(selectedCurrrency.symbol)
                            .font(.mainFont(size: 16))
                            .foregroundColor(Color.exchangerFieldBackgroundNew)
                            .offset(y: 1)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Select Token")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.white.opacity(0.5))
                        Text(selectedCurrrency.symbol)
                            .font(.mainFont(size: 15))
                            .foregroundColor(Color.white.opacity(0.64))
                        CoinImageView(size: 24, url: selectedCurrrency.iconURL).offset(x:10, y:-15)
                    }
                }
                .offset(x: -30)
            }
            .offset(x: 15)
        )
        .frame(width: 158, height: 40)
    }
}

struct TokenSelector_Previews: PreviewProvider {
    static var previews: some View {
        FiatCurrencyButton(currencies: [], selectedCurrrency: .constant(USD))
            .frame(width: 158, height: 40)
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
