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
            switch state.modalView {
            case .sendAsset:
                SendAssetView(
                    coin: state.selectedCoin,
                    currency: state.walletCurrency
                )
            case .receiveAsset:
                ReceiveAssetsView(coin: state.selectedCoin)
            case .allTransactions:
                AssetTxView(coin: state.selectedCoin)
            case .switchAccount:
                AccountsView()
                    .animation(nil)
                    .padding(.top, 24)
                    .padding(.leading, 24)
            case .allNotifications:
                NotificationsView()
                    .animation(nil)
                    .padding(.top, 24)
                    .padding(.trailing, 24)
            case .accountSettings:
                AccountSettingsView()
                    .animation(nil)
                    .padding(.top, 40)
                    .padding(.trailing, 24)
            case .withdrawFromExchange(let balance):
                WithdrawFromExchangeView(balance: balance)
            case .createAlert:
                ManageAlertView(coin: state.selectedCoin)
            default:
                EmptyView()
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
