//
//  WalletModalViews.swift
//  Portal
//
//  Created by Farid on 07.07.2021.
//

import SwiftUI

struct WalletModalViews: View {
    @ObservedObject private var viewModel: WalletSceneViewModel
    
    init(viewModel: WalletSceneViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            if viewModel.sendAsset {
                SendAssetView(
                    wallet: viewModel.wallet,
                    asset: viewModel.selectedAsset,
                    fiatCurrency: viewModel.fiatCurrency,
                    presented: $viewModel.sendAsset
                )
            }
            if viewModel.receiveAsset {
                ReceiveAssetsView(asset: viewModel.selectedAsset, presented: $viewModel.receiveAsset)
            }
            if viewModel.allTransactions {
                AssetTxView(asset: viewModel.selectedAsset, presented: $viewModel.allTransactions)
            }
            if viewModel.createAlert {
                CreateAlertView(asset: viewModel.selectedAsset, presented: $viewModel.createAlert)
            }
        }
        .transition(.scale)
        
        if viewModel.switchWallet {
            SwitchWalletsView(presented: $viewModel.switchWallet)
                .padding(.top, 78)
                .padding(.leading, 24)
        }
        
        if viewModel.allNotifications {
            NotificationsView(presented: $viewModel.allNotifications)
                .padding(.top, 70)
                .padding(.leading, 20)
        }
    }
}


struct WalletModalViews_Previews: PreviewProvider {
    static var previews: some View {
        WalletModalViews(viewModel: .init(wallet: WalletMock(), fiatCurrency: USD))
    }
}
