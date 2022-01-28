//
//  ExchangerView.swift
//  Portal
//
//  Created by Farid on 18.04.2021.
//

import SwiftUI
import Combine

struct ExchangerView: View {
    @ObservedObject var viewModel: ExchangerViewModel
    @Binding var isValid: Bool
    
    init(viewModel: ExchangerViewModel, isValid: Binding<Bool>) {
        self.viewModel = viewModel
        self._isValid = isValid
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount to send")
                .font(.mainFont(size: 12))
                .foregroundColor(Color.coinViewRouteButtonInactive)
            
            HStack(spacing: 4) {
                HStack(spacing: 8) {
                    CoinImageView(size: 24, url: viewModel.coin.icon)
                    
                    #if os(iOS)
                    TextField(String(), text: $viewModel.assetValue)
                        .foregroundColor(Color.lightActiveLabel)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.assetValue.isEmpty,
                                placeholder: "0"
                            )
                        )
                        .frame(height: 20)
                        .keyboardType(.numberPad)
                    #else
                    TextField(String(), text: $viewModel.assetValue)
                        .colorMultiply(.lightInactiveLabel)
                        .foregroundColor(Color.lightActiveLabel)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.assetValue.isEmpty,
                                placeholder: "0"
                            )
                        )
                        .frame(height: 20)
                        .textFieldStyle(PlainTextFieldStyle())
                    #endif
                    
                    Text(viewModel.coin.code)
                        .foregroundColor(Color.lightActiveLabelNew)
                }
                .modifier(TextFieldModifier(cornerRadius: 26))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
                )
                
                Text("=").foregroundColor(Color.coinViewRouteButtonInactive)
                
                HStack(spacing: 8) {
                    FiatCurrencyView(
                        size: 24,
                        currency: .constant(viewModel.currency)
                    )
                    .frame(width: 24, height: 24)
                    
                    #if os(iOS)
                    TextField(String(), text: $viewModel.fiatValue)
                        .foregroundColor(Color.lightActiveLabel)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.fiatValue.isEmpty,
                                placeholder: "0"
                            )
                        )
                        .frame(height: 20)
                        .keyboardType(.numberPad)
                    #else
                    TextField(String(), text: $viewModel.fiatValue)
                        .colorMultiply(.lightInactiveLabel)
                        .foregroundColor(Color.lightActiveLabel)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.fiatValue.isEmpty,
                                placeholder: "0"
                            )
                        )
                        .frame(height: 20)
                        .textFieldStyle(PlainTextFieldStyle())
                    #endif
                    
                    Text(viewModel.currency.code)
                        .foregroundColor(Color.lightActiveLabelNew)
                }
                .modifier(TextFieldModifier(cornerRadius: 26))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
                )
            }
            .font(Font.mainFont(size: 16))
        }
    }
}

struct ExchangerView_Previews: PreviewProvider {
    static var previews: some View {
        let coin = Coin.bitcoin()
        let ticker = Portal.shared.marketDataProvider.ticker(coin: coin)
        let fiatCurrency: Currency = .fiat(USD)
        
        ExchangerView(
            viewModel: .init(coin: coin, currency: fiatCurrency, ticker: ticker),
            isValid: .constant(true)
        )
        .frame(width: 550, height: 200)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
