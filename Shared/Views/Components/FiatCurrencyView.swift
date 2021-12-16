//
//  FiatCurrencyView.swift
//  Portal
//
//  Created by Farid on 29.06.2021.
//

import SwiftUI

struct FiatCurrencyView: View {
    let size: CGFloat

    @Binding var currency: Currency

    private let selectedBgColor = Color(red: 194.0/255.0, green: 194.0/255.0, blue: 199.0/255.0)
    private let bgColor = Color(red: 144.0/255.0, green: 144.0/255.0, blue: 152.0/255.0)
    private let textColor = Color.white
    private let selectedTextColor = Color.white.opacity(0.78)
        
    var body: some View {
        Text(currency.symbol)
            .font(size > 16 ? Font.mainFont(size: 16) : Font.mainFont(size: 12))
            .foregroundColor(foregroundColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .cornerRadius(size/2)
    }
    
    var foregroundColor: Color {
        switch currency {
        case .btc, .eth:
            return selectedTextColor
        default:
            return textColor
        }
    }
    
    var backgroundColor: Color {
        switch currency {
        case .btc, .eth:
            return selectedBgColor
        default:
            return bgColor
        }
    }
}

struct FiatCurrencyView_Previews: PreviewProvider {
    static var previews: some View {
        FiatCurrencyView(size: 40, currency: .constant(Currency.btc))
    }
}
