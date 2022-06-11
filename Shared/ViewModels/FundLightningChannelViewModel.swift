//
//  FundLightningChannelViewModel.swift
//  Portal
//
//  Created by farid on 6/11/22.
//

import Combine
import Coinpaprika

class FundLightningChannelViewModel: ObservableObject {
    let node: LightningNode
    
    @Published var satAmount = String()
    @Published var fiatValue = String()
    @Published var txFeeSelectionIndex = 1
        
    private var subscriptions = Set<AnyCancellable>()
    
    init(node: LightningNode, ticker: Ticker?) {
        self.node = node
        
        let btcPrice = ticker?[.usd].price
        
        $satAmount
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { value in
                "\(((value * (btcPrice?.double ?? 1.0))/1_000_000).rounded(toPlaces: 2))"
            }
            .sink { [weak self] value in
                if value == "0.0" {
                    self?.fiatValue = "0"
                } else {
                    self?.fiatValue = value
                }
            }
            .store(in: &subscriptions)
    }
}

extension FundLightningChannelViewModel {
    static func config(node: LightningNode) -> FundLightningChannelViewModel {
        let ticker = Portal.shared.marketDataProvider.ticker(coin: .bitcoin())
        return FundingLightningChannelViewModel(
            node: node,
            ticker: ticker
        )
    }
}
