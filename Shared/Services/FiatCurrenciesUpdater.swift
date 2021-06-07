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
    let onUpdatePublisher = PassthroughSubject<[FiatCurrency], Never>()
        
    private let jsonDecoder: JSONDecoder
    private let timer: RepeatingTimer
    
    private var subscriptions = Set<AnyCancellable>()
        
    init(
        jsonDecoder: JSONDecoder = JSONDecoder(),
        interval: TimeInterval
    ) {
        self.jsonDecoder = jsonDecoder
        self.timer = RepeatingTimer(timeInterval: interval)
        self.timer.eventHandler = { [unowned self] in            
            self.updateRatesPublisher().combineLatest(self.updateSymbolsPublisher())
                .sink { (completion) in
                    if case let .failure(error) = completion {
                        print(error.localizedDescription)
                    }
                } receiveValue: { (rates, symbols) in
                    onUpdatePublisher.send(
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
        return Future<Rates, NetworkError> { [unowned self] promise in
            guard let url = URL(string: "https://data.fixer.io/api/latest?access_key=13af1e52c56117b6c7d513603fb7cee8&base=USD") else {
                
                return promise(.failure(.inconsistentBehavior))
            }
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { $0.data }
                .decode(type: FiatRatesResponse.self, decoder: jsonDecoder)
                .sink { (completion) in
                    if case let .failure(error) = completion {
                        print(error.localizedDescription)
                        promise(.failure(.networkError))
                    }
                } receiveValue: { (response) in
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
        return Future<[String : String], NetworkError> { [unowned self] promise in
            guard let url = URL(string: "https://data.fixer.io/api/symbols?access_key=13af1e52c56117b6c7d513603fb7cee8&base=USD") else {
                return promise(.failure(.inconsistentBehavior))
            }
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { $0.data }
                .decode(type: FiatSymbols.self, decoder: jsonDecoder)
                .sink { (completion) in
                    if case let .failure(error) = completion {
                        print(error.localizedDescription)
                        promise(.failure(.networkError))
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
