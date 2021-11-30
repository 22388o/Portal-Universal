//
//  WalletCurrencyButton.swift
//  Portal
//
//  Created by Farid on 11.04.2021.
//

import SwiftUI

struct WalletCurrencyButton: View {
    let currencies: [Currency]
    @Binding var selectedCurrrency: Currency
        
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.94))
                .opacity(0.14)
        }
        .overlay(
            Menu {
                ForEach(currencies, id: \.code) { currency in
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
                        Text("Fiat currency")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.white.opacity(0.5))
                        Text(selectedCurrrency.code)
                            .font(.mainFont(size: 15))
                            .foregroundColor(Color.white.opacity(0.64))
                    }
                }
                .offset(x: -30)
            }
            .offset(x: 15)
        )
        .frame(width: 158, height: 40)
    }
}

struct FiatCurrencyButton_Previews: PreviewProvider {
    static var previews: some View {
        WalletCurrencyButton(currencies: [], selectedCurrrency: .constant(.fiat(USD)))
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
