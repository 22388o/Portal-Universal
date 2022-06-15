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
    private let service: ILightningService
    
    @Published var satAmount = String()
    @Published var fiatValue = String()
    @Published var txFeeSelectionIndex = 1
    @Published var fundButtonAvaliable: Bool = false
    
    private var adapter: BitcoinAdapter
    
    var onChainBalanceString: String {
        "\(adapter.balance.rounded(toPlaces: 6))" + " BTC"
    }
        
    private var subscriptions = Set<AnyCancellable>()
    
    init(adapter: BitcoinAdapter, node: LightningNode, ticker: Ticker?, service: ILightningService) {
        self.adapter = adapter
        self.node = node
        self.service = service
        
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
                    self?.fundButtonAvaliable = false
                } else {
                    self?.fiatValue = value
                    self?.fundButtonAvaliable = true
                }
            }
            .store(in: &subscriptions)
    }
    
    func disconectIfNeeded() {
        var shouldDisconnect: Bool = true
        for channel in node.channels {
            if channel.state != .closed {
                shouldDisconnect = false
                break
            }
        }
        if shouldDisconnect && node.connected {
            service.disconnect(node: node)
        }
    }
    
    func openAChannel() {
        guard let amount = Int64(satAmount) else {
            print("Incorrect amount \(satAmount)")
            return
        }
        service.openChannelWith(node: node, sat: amount)
    }
}

extension FundLightningChannelViewModel {
    static func config(node: LightningNode) -> FundLightningChannelViewModel {
        let ticker = Portal.shared.marketDataProvider.ticker(coin: .bitcoin())
        
        guard let service = Portal.shared.lightningService else {
            fatalError("\(#function) lightning service :/")
        }
        
        guard let adapter = Portal.shared.adapterManager.adapter(for: .bitcoin()) as? BitcoinAdapter else {
            fatalError("\(#function) bitcoin adapter :/")
        }
        
        return FundLightningChannelViewModel(
            adapter: adapter,
            node: node,
            ticker: ticker,
            service: service
        )
    }
}
