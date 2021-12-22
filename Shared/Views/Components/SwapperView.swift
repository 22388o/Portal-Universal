//
//  Swapper.swift
//  Portal
//
//  Created by Alexey Melnichenko on 8/19/21.
//

import SwiftUI
import Combine

struct SwapperView: View {
    @ObservedObject private var state: PortalState
    @ObservedObject private var viewModel: SwapperViewModel
    
    init(state: PortalState, viewModel: SwapperViewModel) {
        self.state = state
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SWAP")
                .font(.mainFont(size: 35))
                .foregroundColor(Color.coinViewRouteButtonInactive)
                .padding()
            
            VStack(spacing: 4) {
                ZStack {
#if os(iOS)
                    TextField(String(), text: $viewModel.base.value)
                        .foregroundColor(Color.white)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.base.value.isEmpty,
                                placeholder: "0"
                            )
                        )
                        .frame(height: 20)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color.clear)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
#else
                    TextField(String(), text: $viewModel.base.value)
                        .foregroundColor(Color.white)
                        .background(Color.clear)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.base.value.isEmpty,
                                placeholder: "0"
                            )
                        )
                        .textFieldStyle(PlainTextFieldStyle())
                        .frame(height: 20)
                        .padding(12)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
#endif
                    
                    HStack {
                        Spacer()
                        TokenSelector(
                            tokens: viewModel.tokenList,
                            selectedToken: $viewModel.base.token
                        )
                            .padding(.trailing, 2)
                    }
                }
                
                Text("↓").foregroundColor(Color.coinViewRouteButtonInactive)
                    .padding()
                
                ZStack {
#if os(iOS)
                    TextField(String(), text: $viewModel.quote.value)
                        .allowsHitTesting(false)
                        .foregroundColor(Color.white)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.quote.value.isEmpty,
                                placeholder: "0"
                            )
                        )
                        .frame(height: 20)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color.clear)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
#else
                    TextField(String(), text: $viewModel.quote.value)
                        .allowsHitTesting(false)
                        .foregroundColor(Color.white)
                        .background(Color.clear)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.quote.value.isEmpty,
                                placeholder: "0"
                            )
                        )
                        .textFieldStyle(PlainTextFieldStyle())
                        .frame(height: 20)
                        .padding(12)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
#endif
                    
                    HStack {
                        Spacer()
                        TokenSelector(
                            tokens: viewModel.tokenList,
                            selectedToken: $viewModel.quote.token
                        )
                            .padding(.trailing, 2)
                    }
                }
                
                HStack(spacing: 8){
                    Text("Slippage")
                    Text(viewModel.slippage)
                }
                .foregroundColor(Color.coinViewRouteButtonInactive)
                .padding()
                
                PButton(label: "SWAP", width: 444, height: 55, fontSize: 18, enabled: viewModel.canSwap) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        print("Swap")
                        viewModel.doSwap()
                    }
                }
                .padding(.vertical)
                
                PButton(label: "APPROVE SOURCE TOKEN", width: 444, height: 55, fontSize: 18, enabled: true) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        viewModel.approveToken()
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(width: 444)
        .padding()
    }
}

struct SwapperView_Previews: PreviewProvider {
    static var previews: some View {
        SwapperView(state: PortalState(), viewModel: .config())
            .frame(width: 666, height: 400)
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
