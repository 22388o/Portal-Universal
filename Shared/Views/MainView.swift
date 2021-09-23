//
//  MainView.swift
//  Portal
//
//  Created by Farid on 07.07.2021.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var state = Portal.shared.state
    @StateObject private var walletViewModel = WalletViewModel.config()
    @StateObject private var assetViewModel = AssetViewModel.config()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.58).allowsHitTesting(false)
            
            switch state.mainScene {
            case .wallet:
                HStack(spacing: 0) {
                    switch state.sceneState {
                    case .full:
//                        PortfolioView(viewModel: viewModel.portfolioViewModel)
                        WalletView(state: state, viewModel: walletViewModel)
                        AssetView(viewModel: assetViewModel)
                            .zIndex(0)
                            .padding([.top, .trailing, .bottom], 8)
                    default:
//                        if viewModel.sceneState == .walletPortfolio {
//                            PortfolioView(viewModel: viewModel.portfolioViewModel)
//                                .transition(.move(edge: .leading))
//                        }
                        WalletView(state: state, viewModel: walletViewModel)
                        if state.sceneState == .walletAsset {
                            AssetView(viewModel: assetViewModel)
                                .padding([.top, .trailing, .bottom], 8)
                                .transition(.move(edge: .trailing))
                        }
                    }
                }
            case .exchange:
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
