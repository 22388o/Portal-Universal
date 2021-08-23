//
//  WalletScene.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct WalletScene: View {
    @ObservedObject var state = Portal.shared.state
    @StateObject var headerViewModel = WalletHeaderViewModel.config()
    
    var containerZStackAlignment: Alignment {
        return state.switchWallet || state.allNotifications ? .topLeading : .center
    }
                
    var body: some View {
        ZStack(alignment: containerZStackAlignment) {
            switch state.mainScene {
            case .wallet:
                Color.portalWalletBackground.allowsHitTesting(false)
            case .swap:
                Color.portalSwapBackground.allowsHitTesting(false)
            }
            
            VStack(spacing: 0) {
                WalletHeaderView(viewModel: headerViewModel)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 24)
                
                WalletMainView()
                    .transition(.slide)
                    .cornerRadius(8)
                    .padding([.leading, .bottom, .trailing], 24)
            }
            .blur(radius: state.modalViewIsPresented ? 6 : 0)
//            .scaleEffect(state.scaleEffectRation)
            .allowsHitTesting(!state.modalViewIsPresented)
            
            if state.modalViewIsPresented || state.allNotifications {
                WalletModalViews()
                    .zIndex(1)
            }
        }
    }
}

struct MainScene_Previews: PreviewProvider {
    static var previews: some View {
        WalletScene()
            .iPadLandscapePreviews()
    }
}
