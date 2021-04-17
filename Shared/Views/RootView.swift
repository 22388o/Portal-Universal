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
        if let wallet = walletService.currentWallet {
            WalletScene(wallet: wallet)
        } else {
            CreateWalletScene(walletService: walletService)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(walletService: WalletsService())
            .iPadLandscapePreviews()
    }
}
