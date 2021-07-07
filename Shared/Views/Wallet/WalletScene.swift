//
//  WalletScene.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct WalletScene: View {
    @ObservedObject private var viewModel: WalletSceneViewModel
    @State private var state: Scenes = .wallet
            
    init(wallet: IWallet, fiatCurrency: FiatCurrency) {
        viewModel = .init(wallet: wallet, fiatCurrency: fiatCurrency)
    }
    
    var body: some View {
        ZStack(alignment: viewModel.switchWallet || viewModel.allNotifications ? .topLeading : .center) {
            switch state {
            case .wallet:
                Color.portalWalletBackground.allowsHitTesting(false)
            case .swap:
                Color.portalSwapBackground.allowsHitTesting(false)
            }
            
            VStack(spacing: 0) {
                WalletHeaderView(state: $state, viewModel: viewModel)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 24)
                
                WalletMainView(state: $state, viewModel: viewModel)
                    .cornerRadius(8)
                    .padding([.leading, .bottom, .trailing], 24)
            }
            .blur(radius: viewModel.modalViewIsPresented ? 6 : 0)
            .scaleEffect(viewModel.scaleEffectRation)
            .allowsHitTesting(!viewModel.modalViewIsPresented)
            
            if viewModel.modalViewIsPresented || viewModel.allNotifications {
                WalletModalViews(viewModel: viewModel)
                    .zIndex(1)
            }
        }
    }
}

struct MainScene_Previews: PreviewProvider {
    static var previews: some View {
        WalletScene(wallet: WalletMock(), fiatCurrency: USD)
            .iPadLandscapePreviews()
    }
}
