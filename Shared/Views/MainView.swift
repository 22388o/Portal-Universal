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
    @StateObject private var exchangeViewModel = ExchangeViewModel.config()
    @StateObject private var portfolioViewModel = PortfolioViewModel.config()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.58).allowsHitTesting(false)
            
            switch state.wallet.switchState {
            case .wallet:
                #if os(macOS)
                HStack(spacing: 0) {
                    if state.showPortfolio {
                        PortfolioView(viewModel: portfolioViewModel)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    WalletView(viewModel: walletViewModel)
                    AssetViewLandscape(viewModel: assetViewModel)
                        .padding([.top, .trailing, .bottom], 8)
                }
                #else
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        if state.showPortfolio && (state.orientation == .landscapeLeft || state.orientation == .landscapeRight) {
                            PortfolioView(viewModel: portfolioViewModel)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        WalletView(viewModel: walletViewModel)

                        if state.orientation == .landscapeLeft || state.orientation == .landscapeRight {
                            AssetViewLandscape(viewModel: assetViewModel)
                                .transition(.identity)
                                .id(UUID())
                                .padding([.top, .trailing, .bottom], 8)

                        }
                    }
                    if state.orientation == .portrait || state.orientation == .portraitUpsideDown || state.orientation == .faceDown || state.orientation == .faceUp {
                        AssetViewPortrait(viewModel: assetViewModel)
                            .transition(.identity)
                            .id(UUID())
                            .frame(height: 640)
                            .padding(.all, 8)
                    }
                }
                #endif
            case .exchange:
                if Portal.shared.reachabilityService.isReachable {
                    ExchangeScene(state: state, viewModel: exchangeViewModel)
                        .transition(.identity)
                } else {
                    Text("Exchanges aren't avalible.")
                        .foregroundColor(Color.red)
                        .font(.mainFont(size: 18))
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
