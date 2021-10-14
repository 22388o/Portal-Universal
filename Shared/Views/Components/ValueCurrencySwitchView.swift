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
        HStack(spacing: 12) {
            FiatCurrencyView(
                size: 20,
                state: $state,
                currency: .constant(.fiat(fiatCurrency))
            )
            .contentShape(Rectangle())
            .onTapGesture {
                guard state != .fiat else { return }
                state = .fiat
            }
            
            Group {
                Image("btcIconLight")
                    .resizable()
                    .opacity(state == .btc ? 0.78 : 0.38)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard state != .btc else { return }
                        state = .btc
                    }
                Image("ethIconLight")
                    .resizable()
                    .opacity(state == .eth ? 0.78 : 0.38)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard state != .eth else { return }
                        state = .eth
                    }
            }
            .frame(width: 20, height: 20)
            .foregroundColor(.assetValueLabel)
        }
        
    }
}

struct ValueCurrencySwitchView_Previews: PreviewProvider {
    static var previews: some View {
        ValueCurrencySwitchView(state: .constant(.btc), fiatCurrency: USD, type: .asset)
    }
}
