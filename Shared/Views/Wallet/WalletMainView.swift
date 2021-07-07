//
//  WalletMainView.swift
//  Portal
//
//  Created by Farid on 07.07.2021.
//

import SwiftUI

struct WalletMainView: View {
    @Binding var state: Scenes
    @ObservedObject private var viewModel: WalletSceneViewModel
    
    init(state: Binding<Scenes>, viewModel: WalletSceneViewModel) {
        self._state = state
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.58).allowsHitTesting(false)
            
            switch state {
            case .wallet:
                HStack(spacing: 0) {
                    switch viewModel.sceneState {
                    case .full:
                        PortfolioView(viewModel: viewModel.portfolioViewModel)
                        WalletView(viewModel: viewModel)
                        AssetView(sceneViewModel: viewModel, fiatCurrency: viewModel.fiatCurrency)
                            .padding([.top, .trailing, .bottom], 8)
                    default:
                        if viewModel.sceneState == .walletPortfolio {
                            PortfolioView(viewModel: viewModel.portfolioViewModel)
                                .transition(.move(edge: .leading))
                        }
                        WalletView(viewModel: viewModel)
                        if viewModel.sceneState == .walletAsset {
                            AssetView(sceneViewModel: viewModel, fiatCurrency: viewModel.fiatCurrency)
                                .padding([.top, .trailing, .bottom], 8)
                                .transition(.move(edge: .trailing))
                        }
                    }
                }
            case .swap:
                Text("Swap")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
        .zIndex(0)
    }
}

struct WalletMainView_Previews: PreviewProvider {
    static var previews: some View {
        WalletMainView(state: .constant(.wallet), viewModel: .init(wallet: WalletMock(), fiatCurrency: USD))
    }
}
