//
//  ExchangeDataUpdater.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import Foundation
import Combine

final class ExchangeDataUpdater {
    let onExchangesUpdatePublisher = PassthroughSubject<[ExchangeModel], Never>()
    let onTraidingPairsUpdatePublisher = PassthroughSubject<[TradingPairModel], Never>()
    
    private let baseUrl: String = "https://cryptomarket-api.herokuapp.com/"
    private let supportedExchangesIds: String = "binance,coinbasepro,kraken"
    private let jsonDecoder: JSONDecoder
    private var subscriptions = Set<AnyCancellable>()
    private var urlSession: URLSession
    
    private var supportedExchangesUrl: URL? {
        URL(string: "\(baseUrl)exchange/list")
    }
    
    private var traidingPairsUrl: URL? {
        URL(string: "\(baseUrl)exchange/pairs?ex=\(supportedExchangesIds)")
    }
    
    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        self.urlSession = URLSession(configuration: config)
        
        updateSupportedExchanges()
        updateTraidingPairs()
    }
    
    private func updateSupportedExchanges() {
        guard let url = self.supportedExchangesUrl else { return }
        
        urlSession.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: [ExchangeModel].self, decoder: jsonDecoder)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] exchanges in
                self?.onExchangesUpdatePublisher.send(exchanges)
            }
            .store(in: &subscriptions)
    }
    
    private func updateTraidingPairs() {
        guard let url = self.traidingPairsUrl else { return }
        
        urlSession.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: [TradingPairModel].self, decoder: jsonDecoder)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] traidingPairs in
                self?.onTraidingPairsUpdatePublisher.send(traidingPairs)
            }
            .store(in: &subscriptions)
    }
}
