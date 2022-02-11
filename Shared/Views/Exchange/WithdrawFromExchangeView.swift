//
//  WithdrawFromExchangeView.swift
//  Portal
//
//  Created by Farid on 14.11.2021.
//

import SwiftUI

final class WithdrawFromExchangeViewModel: ObservableObject {
    let coin: Coin = .bitcoin()
    let title: String
    let subtitle = "Bring back your gains into your wallet instantly."
    
    init(balance: ExchangeBalanceModel) {
        title = "Withdraw \(coin.code) from exchange"
    }
}

extension WithdrawFromExchangeViewModel {
    static func config(balance: ExchangeBalanceModel) -> WithdrawFromExchangeViewModel {
        WithdrawFromExchangeViewModel(balance: balance)
    }
}

struct WithdrawFromExchangeView: View {
    
    @ObservedObject private var viewModel: WithdrawFromExchangeViewModel
    @ObservedObject private var state = Portal.shared.state

    init(balance: ExchangeBalanceModel) {
        viewModel = WithdrawFromExchangeViewModel.config(balance: balance)
    }

    var body: some View {
        ModalViewContainer(imageUrl: viewModel.coin.icon, size: CGSize(width: 576, height: 645)) {
            VStack(spacing: 0) {
                Text(viewModel.title)
                    .font(.mainFont(size: 23))
                    .foregroundColor(Color.coinViewRouteButtonActive)
                    .padding(.bottom, 8)
                
                Text(viewModel.subtitle)
                    .foregroundColor(Color.coinViewRouteButtonActive)
                    .font(.mainFont(size: 12))
                    .padding(.bottom, 34)
                
                Spacer()
            }
            .padding(.top, 57)
            .transition(.identity)
        }
        .allowsHitTesting(true)
    }
}

