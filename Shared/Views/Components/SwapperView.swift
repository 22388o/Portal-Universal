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
            /*Text("SWAP")
                .font(.mainFont(size: 33))
                .foregroundColor(Color.coinViewRouteButtonInactive)*/

            
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    /*CoinImageView(size: 24, url: "https://cryptologos.cc/logos/ethereum-eth-logo.png")*/
                    
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
                    
                    /*Text("WETH")
                        .foregroundColor(Color.lightActiveLabelNew)*/
                    
                }
                .modifier(TextFieldModifier())
                .frame(width: 444)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.clear, lineWidth: 1)
                )
                TokenSelector(
                    currencies: viewModel.tokenList,
                    selectedCurrrency: $viewModel.selectionA
                ).offset(x: 150, y:-53)
                
                Text("↓").foregroundColor(Color.coinViewRouteButtonInactive)
                    .offset(x: 0, y:-23)
                
                HStack(spacing: 8) {
                    /*CoinImageView(size: 24, url: "https://cryptologos.cc/logos/chainlink-link-logo.png")*/
                    
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
                    
                    /*Text("LINK")
                        .foregroundColor(Color.lightActiveLabelNew)*/
                    
                     
                }
                .modifier(TextFieldModifier())
                .frame(width: 444)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.clear, lineWidth: 1)
                )
                
                TokenSelector(
                    currencies: viewModel.tokenList,
                    selectedCurrrency: $viewModel.selectionB
                ).offset(x: 150, y:-50)
                
                HStack(spacing: 8){                    Text("Slippage").foregroundColor(Color.coinViewRouteButtonInactive)
                    Text(viewModel.slippage).foregroundColor(Color.coinViewRouteButtonInactive)
                }.offset(x: 0, y:-25)
                                
                 
                
                PButton(label: "SWAP", width: 444, height: 55, fontSize: 12, enabled: true) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        print("Swap")
                        viewModel.doSwap()
                    }
                }
                
                Text(" ").foregroundColor(Color.coinViewRouteButtonInactive)
                
                
                /*Text(" ").foregroundColor(Color.coinViewRouteButtonInactive)
                
                PButton(label: "Approve", width: 224, height: 32, fontSize: 12, enabled: true) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        print("Approve")
                        viewModel.approveWeth()
                    }
                }*/
                
                /*Picker(selection: $viewModel.selectionA, label: Text("Zeige Deteils")) {
                   Text("Schmelzpunkt").tag(1)
                   Text("Instrumentelle Analytik").tag(2)
                }*/
                               
                HStack(spacing: 8) {
                    PButton(label: "APPROVE SOURCE TOKEN", width: 444, height: 55, fontSize: 12, enabled: true) {
                        withAnimation(.easeIn(duration: 0.2)) {
                            print("Approve1")
                            viewModel.approveToken()
                        }
                    }
                }
            }
            .font(Font.mainFont(size: 16))
        }
    }
}

struct SwapperView_Previews: PreviewProvider {
    static var previews: some View {
        SwapperView(state: PortalState(), viewModel: .init())
            .frame(width: 666, height: 400)
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
