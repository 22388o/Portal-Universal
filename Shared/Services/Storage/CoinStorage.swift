//
//  Erc20Updater.swift
//  Portal
//
//  Created by Farid on 28.07.2021.
//

import Foundation
import Combine
import Coinpaprika

final class CoinStorage: ICoinStorage, ObservableObject {
    var onCoinsUpdatePublisher = PassthroughSubject<[Coin], Never>()
    var coins: [Coin] = []
    
    private var tokens: [Erc20TokenCodable] = []
    
    private let jsonDecoder: JSONDecoder
    private let marketData: MarketDataRepository
    private var subscriptions = Set<AnyCancellable>()
    
    @Published private var tokensReady: Bool = false
    
    private var url: URL? {
        URL(string: "https://cryptomarket-api.herokuapp.com/erc20_token_list")
    }
    
    init(marketData: MarketDataRepository, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        self.marketData = marketData
        
        updateErc20TokensData()
        
        marketData.$tickersReady.combineLatest($tokensReady)
            .receive(on: DispatchQueue.global())
            .sink { [weak self] _tickersReady, _tokensReady  in
                guard let self = self else { return }
                if _tickersReady && _tokensReady {
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
        tokensReady = true
    }
    
    
    private func updateErc20TokensData() {
        guard let url = self.url else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .tryMap { $0.data }
            .decode(type: [String : Erc20TokenCodable].self, decoder: jsonDecoder)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] erc20Tokens in
                guard let self = self else { return }
                let valildTokens = erc20Tokens.map{ $0.value }.filter { !$0.iconURL.isEmpty }
                self.tokens = valildTokens
                self.tokensReady = !self.tokens.isEmpty
            }
            .store(in: &subscriptions)
    }
}
