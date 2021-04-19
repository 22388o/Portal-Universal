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
    
    init(viewModel: ExchangerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount to send")
                .font(.mainFont(size: 12))
                .foregroundColor(Color.coinViewRouteButtonInactive)

            
            HStack(spacing: 4) {
                HStack(spacing: 8) {
                    viewModel.asset.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    TextField("", text: $viewModel.assetValue)
                        .foregroundColor(Color.lightActiveLabel)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.assetValue.isEmpty,
                                placeholder: "0.0"
                            )
                        )
                        .frame(height: 20)
                        .keyboardType(.numberPad)
                    
                    Text(viewModel.asset.code)
                        .foregroundColor(Color.lightActiveLabelNew)
                }
                .modifier(TextFieldModifier())
                .frame(width: 224)
                
                Text("=")
                    .foregroundColor(Color.coinViewRouteButtonInactive)
                
                HStack(spacing: 8) {
                    FiatCurrencyView(
                        size: 24,
                        state: .constant(.fiat),
                        currency: .constant(.fiat(USD))
                    )
                    .frame(width: 24, height: 24)
                    
                    TextField("", text: $viewModel.fiatValue)
                        .foregroundColor(Color.lightActiveLabel)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.fiatValue.isEmpty,
                                placeholder: "0.0"
                            )
                        )
                        .frame(height: 20)
                        .keyboardType(.numberPad)
                    
                    Text(viewModel.fiat.code)
                        .foregroundColor(Color.lightActiveLabelNew)
                }
                .modifier(TextFieldModifier())
                .frame(width: 224)
            }
            .font(Font.mainFont(size: 16))
        }
    }
}

struct ExchangerView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangerView(viewModel: .init(asset: Coin(
            code: "ETH",
            name: "Ethereum",
            icon:  Image("iconEth")),
            fiat: USD)
        )
        .frame(width: 550, height: 200)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
