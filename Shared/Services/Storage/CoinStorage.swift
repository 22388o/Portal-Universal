//
//  Erc20Updater.swift
//  Portal
//
//  Created by Farid on 28.07.2021.
//

import Foundation
import Combine
import Coinpaprika

final class CoinStorage: ICoinStorage {
    var onCoinsUpdatePublisher = PassthroughSubject<[Coin], Never>()
    
    var coins: [Coin] = []
    
    private var tokens: [Erc20TokenCodable] = []
    
    private let jsonDecoder: JSONDecoder
    private var subscriptions = Set<AnyCancellable>()
    
    private var url: URL? {
        URL(string: "https://cryptomarket-api.herokuapp.com/erc20_token_list")
    }
    
    init(marketData: MarketDataRepository, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        
        loadTokensData()
        
        marketData.$tickersReady
            .receive(on: DispatchQueue.global())
            .sink { [weak self] ready in
                guard let self = self else { return }
                if ready {
                    self.coins = self.tokens.compactMap {
                        Coin(type: .erc20(address: $0.contractAddress), code: $0.symbol, name: $0.name, decimal: $0.decimal, iconUrl: $0.iconURL)
                    }
                    .filter{ marketData.ticker(coin: $0) != nil }
                    .sorted(by: { $0.code < $1.code })
                    
                    self.onCoinsUpdatePublisher.send(self.coins)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func loadTokensData() {
        guard let data = erc20JSON.data(using: .utf8) else { return }
        guard let allTokens = try? jsonDecoder.decode([String : Erc20TokenCodable].self, from: data) else { return }
        
        tokens = allTokens.map{ $0.value }.filter { !$0.iconURL.isEmpty }
        
//        coins = tokens.compactMap {
//            Coin(type: .erc20(address: $0.contractAddress), code: $0.symbol, name: $0.name, decimal: $0.decimal)
//        }
//        .sorted(by: { $0.code < $1.code })
    }
    
    
    private func updateErc20TokensData() {
        guard let url = self.url else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: [String : Erc20TokenCodable].self, decoder: jsonDecoder)
            .sink { (completion) in
                if case let .failure(error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { erc20Tokens in
                let valildTokens = erc20Tokens.map{ $0.value }.filter { !$0.iconURL.isEmpty }
                print(valildTokens.count)
            }
            .store(in: &subscriptions)
    }
}
