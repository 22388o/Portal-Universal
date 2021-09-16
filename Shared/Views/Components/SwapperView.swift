//
//  Swapper.swift
//  Portal
//
//  Created by Alexey Melnichenko on 8/19/21.
//

import SwiftUI
import Combine

struct SwapperView: View {
    @ObservedObject var state: PortalState
    @ObservedObject var viewModel: SwapperViewModel
    
    
    init(state: PortalState, viewModel: SwapperViewModel) {
        self.state = state
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount to send")
                .font(.mainFont(size: 12))
                .foregroundColor(Color.coinViewRouteButtonInactive)

            
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    CoinImageView(size: 24, url: "https://cryptologos.cc/logos/ethereum-eth-logo.png")
                    
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
                    
                    Text("WETH")
                        .foregroundColor(Color.lightActiveLabelNew)
                }
                .modifier(TextFieldModifier())
                .frame(width: 224)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.clear, lineWidth: 1)
                )
                
                Text("↓").foregroundColor(Color.coinViewRouteButtonInactive)
                
                HStack(spacing: 8) {
                    CoinImageView(size: 24, url: "https://cryptologos.cc/logos/chainlink-link-logo.png")
                    
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
                    
                    Text("LINK")
                        .foregroundColor(Color.lightActiveLabelNew)
                }
                .modifier(TextFieldModifier())
                .frame(width: 224)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.clear, lineWidth: 1)
                )
            }
            .font(Font.mainFont(size: 16))
        }
    }
}

struct SwapperView_Previews: PreviewProvider {
    static var previews: some View {
        SwapperView(state: PortalState(), viewModel: .init())
            .frame(width: 550, height: 200)
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
