//
//  ExchangeManager.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import Foundation
import Combine

final class ExchangeManager: ObservableObject {
    @Published var allSupportedExchanges: [ExchangeModel] = []
    @Published var tradingPairs: [TradingPairModel] = []
        
    private let exchangeDataUpdater: ExchangeDataUpdater
    private let secureStorage: IKeychainStorage
    private let localStorage: ILocalStorage
    private let notificationService: NotificationService
    private let binanceApi: BinanceApi = BinanceApi()
    private let coinbaseApi: CoinbaseProApi = CoinbaseProApi()
    private let krakenApi: KrakenApi = KrakenApi()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var syncedExchanges: [ExchangeModel] {
        let syncedExchangesIds = localStorage.syncedExchangesIds
        return allSupportedExchanges.filter{ syncedExchangesIds.contains($0.id) }
    }
    
    init(localStorage: ILocalStorage, secureStorage: IKeychainStorage, exchangeDataUpdater: ExchangeDataUpdater, notificationService: NotificationService) {
        self.localStorage = localStorage
        self.secureStorage = secureStorage
        self.exchangeDataUpdater = exchangeDataUpdater
        self.notificationService = notificationService
        
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
    
    func updateBalances() {
        for exchange in syncedExchanges {
            if let credentials = credentials(exchange: exchange) {
                switch credentials.service {
                case .binance:
                    binanceApi.fetchBalance(credentials: credentials)?
                        .sink(receiveCompletion: { completion in
                            print(completion)
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
    
    func fetchOrders(tradingData: TradingData, onFetch: @escaping () -> ()) {
        if let exchange = tradingData.exchange, let credentials = credentials(exchange: exchange) {
            switch credentials.service {
            case .binance:
                binanceApi.orders(credentials: credentials, symbol: tradingData.currentPair.symbol)?
                        .sink(receiveCompletion: { completion in
                            print(completion)
                            switch completion {
                            case .failure(_ ):
                                exchange.orders = []
                            case .finished:
                                break
                            }
                            onFetch()
                        }, receiveValue: { orders in
                            exchange.orders = orders ?? []
                        })
                        .store(in: &subscriptions)
            case .coinbasepro:
                coinbaseApi.orders(credentials: credentials, symbol: "")?
                    .sink(receiveCompletion: { completion in
                        print(completion)
                        onFetch()
                    }, receiveValue: { orders in
                        exchange.orders = orders ?? []
                    })
                    .store(in: &subscriptions)
            case .kraken:
                onFetch()
            case .none:
                onFetch()
            }
        }
    }
    
    func placeOrder(tradingData: TradingData, type: OrderType, side: OrderSide, amount: String, price: String) -> AnyPublisher<Bool, NetworkError>? {
        guard let exchange = tradingData.exchange else {
            return Fail(outputType: Bool.self, failure: NetworkError.error("[Portal] Trading data has no exchange")).eraseToAnyPublisher()
        }
        
        let orderType: String = type.rawValue.uppercased()
        let orderSide: String = side.rawValue.uppercased()
        let priceValue = Double(price) ?? 0
        
        guard
            let quantityValue = Double(amount),
            let symbol = tradingData.currentPair.exchange.filter({ $0.id == exchange.id }).first?.sym
        else {
            return Fail(outputType: Bool.self, failure: NetworkError.error("[Portal] Trading pair symbol is missing")).eraseToAnyPublisher()
        }
                
        if let credentials = credentials(exchange: exchange) {
            switch credentials.service {
            case .binance:
                return binanceApi.placeOrder(credentials: credentials, type: orderType, side: orderSide, symbol: symbol, price: priceValue, quantity: quantityValue)
            case .coinbasepro:
                return coinbaseApi.placeOrder(credentials: credentials, type: orderType, side: orderSide, symbol: symbol, price: priceValue, quantity: quantityValue)
            case .kraken:
                return Fail(outputType: Bool.self, failure: NetworkError.error("[Portal] Kraken isn't supported yet")).eraseToAnyPublisher()
            case .none:
                return Fail(outputType: Bool.self, failure: NetworkError.error("[Portal] Unsupported exchange")).eraseToAnyPublisher()
            }
        } else {
            return Fail(outputType: Bool.self, failure: NetworkError.error("[Portal] Exchange credentials is missing")).eraseToAnyPublisher()
        }
    }
    
    func cancel(exchange: ExchangeModel, order: ExchangeOrderModel) -> AnyPublisher<Data, NetworkError>? {
        if let credentials = credentials(exchange: exchange), let symbol = order.symbol {
            switch credentials.service {
            case .binance:
                return binanceApi.cancelOrder(credentials: credentials, symbol: symbol, orderID: order.id)
            case .coinbasepro:
                return Fail(outputType: Data.self, failure: NetworkError.error("[Portal] Coinbase isn't supported yet")).eraseToAnyPublisher()
            case .kraken:
                return Fail(outputType: Data.self, failure: NetworkError.error("[Portal] Kraken isn't supported yet")).eraseToAnyPublisher()
            case .none:
                return Fail(outputType: Data.self, failure: NetworkError.error("[Portal] Unsupported exchange")).eraseToAnyPublisher()
            }
        } else {
            return Fail(outputType: Data.self, failure: NetworkError.error("[Portal] Exchange credentials is missing")).eraseToAnyPublisher()
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
