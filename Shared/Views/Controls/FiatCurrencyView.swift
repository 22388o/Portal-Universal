//
//  FiatCurrencyView.swift
//  Portal
//
//  Created by Farid on 29.06.2021.
//

import SwiftUI

struct FiatCurrencyView: View {
    let size: CGFloat

    @Binding var state: ValueCurrencySwitchState
    @Binding var currency: Currency

    private let selectedBgColor = Color.white.opacity(0.78)
    private let bgColor = Color(red: 66.0/255.0, green: 73.0/255.0, blue: 84.0/255.0)
    private let textColor = Color.white//(red: 6.0/255.0, green: 42.0/255.0, blue: 60.0/255.0)
    private let selectedTextColor = Color(red: 21.0/255.0, green: 52.0/255.0, blue: 66.0/255.0)
        
    var body: some View {
        Text(currency.symbol)
            .font(size > 16 ? Font.mainFont(size: 16) : Font.mainFont(size: 12))
            .foregroundColor(state == .fiat ? textColor : selectedTextColor)
            .frame(width: size, height: size)
            .background(state == .fiat ? bgColor : selectedBgColor)
            .cornerRadius(size/2)
    }
}

struct FiatCurrencyView_Previews: PreviewProvider {
    static var previews: some View {
        FiatCurrencyView(size: 40, state: .constant(.btc), currency: .constant(Currency.btc))
    }
}
