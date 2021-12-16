//
//  FiatCurrenciesUpdater.swift
//  Portal
//
//  Created by Farid on 14.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

typealias Rates = [String : Double]

struct FiatRatesResponse: Codable {
    let success: Bool
    let rates: Rates?
}

struct FiatSymbols: Codable {
    let success: Bool
    let symbols: [String: String]?
}

final class FiatCurrenciesUpdater { 
    let onFiatCurrenciesUpdate = PassthroughSubject<[FiatCurrency], Never>()
        
    private let jsonDecoder: JSONDecoder
    private let timer: RepeatingTimer
    private let apiKey: String
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var urlSession: URLSession
    
    private var latestUrl: URL? {
        URL(string: "https://data.fixer.io/api/latest?access_key=\(apiKey)&base=USD")
    }
    
    private var symbolsUrl: URL? {
        URL(string: "https://data.fixer.io/api/symbols?access_key=\(apiKey)&base=USD")
    }
        
    init(
        jsonDecoder: JSONDecoder = JSONDecoder(),
        interval: TimeInterval,
        fixerApiKey: String
    ) {
        self.jsonDecoder = jsonDecoder
        self.timer = RepeatingTimer(timeInterval: interval)
        self.apiKey = fixerApiKey
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        self.urlSession = URLSession(configuration: config)
        
        self.timer.eventHandler = { [unowned self] in
            self.updateRatesPublisher().combineLatest(self.updateSymbolsPublisher())
                .sink { (completion) in
                    if case let .failure(error) = completion {
                        print(error)
                    }
                } receiveValue: { (rates, symbols) in
                    onFiatCurrenciesUpdate.send(
                        zip(
                            symbols.sorted(by: { $0.key < $1.key }),
                            rates.sorted(by: { $0.key < $1.key })
                        )
                        .map {
                            FiatCurrency(code: $0.key, name: $0.value, rate: $1.value)
                        }
                    )
                }
                .store(in: &self.subscriptions)

        }
        self.timer.resume()
    }
    
    private func updateRatesPublisher() -> Future<Rates, NetworkError> {
        Future<Rates, NetworkError> { [unowned self] promise in
            guard let url = latestUrl else {
                return promise(.failure(.inconsistentBehavior))
            }
            urlSession.dataTaskPublisher(for: url)
                .tryMap { $0.data }
                .decode(type: FiatRatesResponse.self, decoder: jsonDecoder)
                .sink { (completion) in
                    if case let .failure(error) = completion {
                        promise(.failure(.error(error.localizedDescription)))
                    }
                } receiveValue: { response in
                    if response.success, let rates = response.rates {
                        promise(.success(rates))
                    } else {
                        promise(.failure(.networkError))
                    }
                }
                .store(in: &subscriptions)

        }
    }
    
    private func updateSymbolsPublisher() -> Future<[String : String], NetworkError> {
        Future<[String : String], NetworkError> { [unowned self] promise in
            guard let url = symbolsUrl else {
                return promise(.failure(.inconsistentBehavior))
            }
            urlSession.dataTaskPublisher(for: url)
                .tryMap { $0.data }
                .decode(type: FiatSymbols.self, decoder: jsonDecoder)
                .sink { (completion) in
                    if case let .failure(error) = completion {
                        promise(.failure(.error(error.localizedDescription)))
                    }
                } receiveValue: { (response) in
                    if response.success, let symbols = response.symbols {
                        promise(.success(symbols))
                    } else {
                        promise(.failure(.networkError))
                    }
                }
                .store(in: &subscriptions)
        }
    }
    
    func pause() {
        timer.suspend()
    }
    
    func resume() {
        timer.resume()
    }
}
