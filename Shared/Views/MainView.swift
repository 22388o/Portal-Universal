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
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.58).allowsHitTesting(false)
            
            switch state.mainScene {
            case .wallet:
                HStack(spacing: 0) {
                    WalletView(state: state, viewModel: walletViewModel)
                    AssetView(viewModel: assetViewModel)
                        .zIndex(0)
                        .padding([.top, .trailing, .bottom], 8)
                }
            case .exchange:
                ExchangeScene(viewModel: exchangeViewModel)
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
