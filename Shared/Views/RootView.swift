//
//  RootView.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

struct RootView: View {
    @ObservedObject private var walletService: WalletsService

    init(walletService: WalletsService) {
        self.walletService = walletService
    }
    
    var body: some View {
        ZStack {
            Color.portalWalletBackground
            
            if walletService.currentWallet != nil {
                WalletScene(walletService: walletService)
                    .transition(AnyTransition.scale.combined(with: .opacity))
                    .zIndex(1)
            } else {
                CreateWalletScene(walletService: walletService)
                    .transition(AnyTransition.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(walletService: WalletsService())
            .iPadLandscapePreviews()
    }
}
