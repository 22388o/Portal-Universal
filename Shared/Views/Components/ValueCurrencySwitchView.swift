//
//  ValueCurrencySwitchView.swift
//  Portal
//
//  Created by Farid on 29.06.2021.
//

import SwiftUI

struct ValueCurrencySwitchView: View {
    @Binding var state: ValueCurrencySwitchState
    let fiatCurrency: FiatCurrency
    let type: AssetMarketValueViewType
    
    var body: some View {
        HStack(spacing: 4) {
            FiatCurrencyView(
                size: 16,
                state: $state,
                currency: .constant(.fiat(fiatCurrency))
            )
            Group {
                Image("btcIconLight")
                    .resizable()
                    .opacity(state == .btc ? 0.78 : 0.38)
                Image("ethIconLight")
                    .resizable()
                    .opacity(state == .eth ? 0.78 : 0.38)
            }
            .frame(width: 16, height: 16)
            .foregroundColor(.assetValueLabel)
        }
        
    }
}

struct ValueCurrencySwitchView_Previews: PreviewProvider {
    static var previews: some View {
        ValueCurrencySwitchView(state: .constant(.btc), fiatCurrency: USD, type: .asset)
    }
}
