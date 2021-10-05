//
//  ExchangeManager.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import Foundation
import Combine

final class ExchangeManager {
    var allSupportedExchanges: [ExchangeModel] = []
    var tradingPairs: [TradingPairModel] = []
        
    private let exchangeDataUpdater: ExchangeDataUpdater
    private let secureStorage: IKeychainStorage
    private let localStorage: ILocalStorage
    private let binanceApi: BinanceApi = BinanceApi()
    private let coinbaseApi: CoinbaseProApi = CoinbaseProApi()
    private let krakenApi: KrakenApi = KrakenApi()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var syncedExchanges: [ExchangeModel] {
        let syncedExchangesIds = localStorage.syncedExchangesIds
        return allSupportedExchanges.filter{ syncedExchangesIds.contains($0.id) }
    }
    
    init(localStorage: ILocalStorage, secureStorage: IKeychainStorage, exchangeDataUpdater: ExchangeDataUpdater) {
        self.localStorage = localStorage
        self.secureStorage = secureStorage
        self.exchangeDataUpdater = exchangeDataUpdater
        
        self.setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        exchangeDataUpdater.onExchangesUpdatePublisher
            .sink(receiveValue: { [weak self] models in
                self?.allSupportedExchanges = models.filter{$0.id == "binance"}
                self?.updateBalances()
            })
            .store(in: &subscriptions)
        
        exchangeDataUpdater.onTraidingPairsUpdatePublisher
            .sink(receiveValue: { [weak self] models in
                self?.tradingPairs = models
            })
            .store(in: &subscriptions)
        
        Timer.publish(every: 360, on: .current, in: .default)
            .autoconnect()
            .sink { [weak self] timer in
                self?.updateBalances()
            }
            .store(in: &subscriptions)
    }
    
    private func updateBalances() {
        for exchange in syncedExchanges {
            if let credentials = credentials(exchange: exchange) {
                switch credentials.service {
                case .binance:
                    binanceApi.fetchBalance(credentials: credentials)?
                        .sink(receiveCompletion: { completion in
                            print(completion.self)
                        }, receiveValue: { balances in
                            exchange.balances = balances
                        })
                        .store(in: &subscriptions)
                    break
                case .coinbasepro:
                    coinbaseApi.fetchBalance(credentials: credentials)?
                        .sink(receiveCompletion: { completion in
                            print(completion)
                        }, receiveValue: { balances in
                            exchange.balances = balances
                        })
                        .store(in: &subscriptions)
                case .kraken:
                    break
                case .none:
                    break
                }
            }
        }
    }
    
    private func credentials(exchange: ExchangeModel) -> ExchangeCredentials? {
        let exchangeId = exchange.id
        
        guard
            let key: String = recover(id: exchangeId, keyName: .key),
            let secret: String = recover(id: exchangeId, keyName: .secret)
        else {
            return nil
        }
        
        if let passphrase: String = recover(id: exchangeId, keyName: .passphrase) {
            return ExchangeCredentials(name: exchangeId, key: key, secret: secret, passphrase: passphrase)
        } else {
            return ExchangeCredentials(name: exchangeId, key: key, secret: secret)
        }
    }
    
    private func secureKey(id: String, keyName: KeyName) -> String {
        "\(keyName.rawValue)_\(id)"
    }

    private func store<T: LosslessStringConvertible>(_ value: T, id: String, keyName: KeyName) throws {
        let key = secureKey(id: id, keyName: keyName)
        try secureStorage.set(value: value, for: key)
    }

    private func recover<T: LosslessStringConvertible>(id: String, keyName: KeyName) -> T? {
        let key = secureKey(id: id, keyName: keyName)
        return secureStorage.value(for: key)
    }
    
    func sync(exchange: ExchangeModel, secret: String, key: String, passphrase: String?) {
        let exchangeId = exchange.id
        
        do {
            try store(secret, id: exchangeId, keyName: .secret)
            try store(key, id: exchangeId, keyName: .key)
            
            if let pass = passphrase, exchangeId == "coinbasepro" {
                try store(pass, id: exchangeId, keyName: .passphrase)
            }
            
            localStorage.addSyncedExchange(id: exchangeId)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func fetchOpenOrders() {
        for exchange in syncedExchanges {
            if let credentials = credentials(exchange: exchange) {
                switch credentials.service {
                case .binance:
                        binanceApi.openOrders(credentials: credentials)?
                            .sink(receiveCompletion: { completion in
                                print(completion)
                            }, receiveValue: { orders in
                                exchange.orders = orders ?? []
                            })
                            .store(in: &subscriptions)
                case .coinbasepro:
                    coinbaseApi.orders(credentials: credentials, symbol: "")?
                        .sink(receiveCompletion: { completion in
                            print(completion)
                        }, receiveValue: { orders in
                            exchange.orders = orders ?? []
                        })
                        .store(in: &subscriptions)
                case .kraken:
                    break
                case .none:
                    break
                }
            }
        }
    }
    
    func placeOrder(tradingData: TradingData, type: OrderType, side: OrderSide, amount: String, price: String) {
        guard let exchange = tradingData.exchange else { return }
        
        let orderType: String = type.rawValue.uppercased()
        let orderSide: String = side.rawValue.uppercased()
        let priceValue = Double(price) ?? 0
        
        guard
            let quantityValue = Double(amount),
            let symbol = tradingData.currentPair.exchange.filter({ $0.id == exchange.id }).first?.sym
        else { return }
                
        if let credentials = credentials(exchange: exchange) {
            switch credentials.service {
            case .binance:
                    binanceApi.placeOrder(credentials: credentials, type: orderType, side: orderSide, symbol: symbol, price: priceValue, quantity: quantityValue)?
                        .sink(receiveCompletion: { [weak self] completion in
                            print(completion)
                            switch completion {
                            case .failure(let error):
                                print(error)
                            case .finished:
                                self?.updateBalances()
                                self?.fetchOpenOrders()
                            }
                        }, receiveValue: { order in
                            print(order)
                        })
                        .store(in: &subscriptions)
            case .coinbasepro:
                coinbaseApi.orders(credentials: credentials, symbol: "")?
                    .sink(receiveCompletion: { completion in
                        print(completion)
                    }, receiveValue: { orders in
                        exchange.orders = orders ?? []
                    })
                    .store(in: &subscriptions)
            case .kraken:
                break
            case .none:
                break
            }
        }
        
    }
}

extension ExchangeManager {
    private enum KeyName: String {
        case secret
        case key
        case passphrase
    }
}
