//
//  WalletScene.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct WalletScene: View {
    @ObservedObject var portalState = Portal.shared.state
                
    var body: some View {
        ZStack(alignment: portalState.switchWallet || portalState.allNotifications ? .topLeading : .center) {
            switch portalState.mainScene {
            case .wallet:
                Color.portalWalletBackground.allowsHitTesting(false)
            case .swap:
                Color.portalSwapBackground.allowsHitTesting(false)
            }
            
            VStack(spacing: 0) {
                WalletHeaderView(state: $portalState.mainScene, accountName: Portal.shared.accountManager.activeAccount?.name ?? "no name")
                    .padding(.horizontal, 48)
                    .padding(.vertical, 24)
                
                WalletMainView()
                    .transition(.slide)
                    .cornerRadius(8)
                    .padding([.leading, .bottom, .trailing], 24)
            }
            .blur(radius: portalState.modalViewIsPresented ? 6 : 0)
            .scaleEffect(portalState.scaleEffectRation)
            .allowsHitTesting(!portalState.modalViewIsPresented)
            
            if portalState.modalViewIsPresented || portalState.allNotifications {
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
