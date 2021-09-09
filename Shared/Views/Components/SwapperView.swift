//
//  Swapper.swift
//  Portal
//
//  Created by Alexey Melnichenko on 8/19/21.
//

import SwiftUI
import Combine

struct SwapperView: View {
    @ObservedObject var viewModel: SwapperViewModel
    @Binding var isValid: Bool
    
    init(viewModel: SwapperViewModel, isValid: Binding<Bool>) {
        self.viewModel = viewModel
        self._isValid = isValid
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount to send")
                .font(.mainFont(size: 12))
                .foregroundColor(Color.coinViewRouteButtonInactive)

            
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    CoinImageView(size: 24, url: viewModel.coin.icon)
                    
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
                    
                    Text(viewModel.coin.code)
                        .foregroundColor(Color.lightActiveLabelNew)
                }
                .modifier(TextFieldModifier())
                .frame(width: 224)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
                )
                
                Text("↓").foregroundColor(Color.coinViewRouteButtonInactive)
                
                HStack(spacing: 8) {
                    FiatCurrencyView(
                        size: 24,
                        state: .constant(.btc),
                        currency: .constant(.fiat(viewModel.fiat))
                    )
                    .frame(width: 24, height: 24)
                    
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
                    
                    Text(viewModel.fiat.code)
                        .foregroundColor(Color.lightActiveLabelNew)
                }
                .modifier(TextFieldModifier())
                .frame(width: 224)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
                )
            }
            .font(Font.mainFont(size: 16))
        }
    }
}

struct SwapperView_Previews: PreviewProvider {
    static var previews: some View {
        SwapperView(viewModel: .init(coin: Coin.bitcoin(), fiat: USD), isValid: .constant(true))
            .frame(width: 550, height: 200)
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
