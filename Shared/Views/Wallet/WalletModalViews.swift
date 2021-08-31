//
//  WalletModalViews.swift
//  Portal
//
//  Created by Farid on 07.07.2021.
//

import SwiftUI

struct WalletModalViews: View {
    @ObservedObject private var state: PortalState = Portal.shared.state
    
    var body: some View {
        Group {
            if state.sendAsset {
                SendAssetView(
                    coin: state.selectedCoin,
                    fiatCurrency: state.fiatCurrency,
                    presented: $state.sendAsset
                )
            }
            if state.receiveAsset {
                ReceiveAssetsView(coin: state.selectedCoin)
            }
            if state.allTransactions {
                AssetTxView(coin: state.selectedCoin)
            }
            if state.createAlert {
                //CreateAlertView(asset: state.selectedAsset, presented: $state.createAlert)
            }
            
            if state.switchWallet {
                AccountsView()
                    .animation(nil)
                    .padding(.top, 24)
                    .padding(.leading, 24)
            }
            
            if state.allNotifications {
                NotificationsView(presented: $state.allNotifications)
                    .animation(nil)
                    .padding(.top, 24)
                    .padding(.leading, 24)
            }
            
        }
        .transition(AnyTransition.identity)
    }
}


struct WalletModalViews_Previews: PreviewProvider {
    static var previews: some View {
        WalletModalViews()
    }
}
