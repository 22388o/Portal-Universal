//
//  WalletMainView.swift
//  Portal
//
//  Created by Farid on 07.07.2021.
//

import SwiftUI

struct WalletMainView: View {
    @ObservedObject private var state = Portal.shared.state
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.58).allowsHitTesting(false)
            
            switch state.mainScene {
            case .wallet:
                HStack(spacing: 0) {
                    switch state.sceneState {
                    case .full:
//                        PortfolioView(viewModel: viewModel.portfolioViewModel)
                        WalletView()
                        AssetView(fiatCurrency: USD)
                            .zIndex(0)
                            .padding([.top, .trailing, .bottom], 8)
                    default:
//                        if viewModel.sceneState == .walletPortfolio {
//                            PortfolioView(viewModel: viewModel.portfolioViewModel)
//                                .transition(.move(edge: .leading))
//                        }
                        WalletView()
                        if state.sceneState == .walletAsset {
                            AssetView(fiatCurrency: USD)
                                .padding([.top, .trailing, .bottom], 8)
                                .transition(.move(edge: .trailing))
                        }
                    }
                }
            case .swap:
                HStack {
                    Spacer()
                        .frame(width: 320)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.94))
                        .padding(8)
                }
            }
        }
        .zIndex(0)
        .onReceive(Portal.shared.$marketDataReady.dropFirst(), perform: { dataIsLoaded in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                state.selectedCoin = Coin.bitcoin()
            }
        })
    }
}

struct WalletMainView_Previews: PreviewProvider {
    static var previews: some View {
        WalletMainView()
    }
}
