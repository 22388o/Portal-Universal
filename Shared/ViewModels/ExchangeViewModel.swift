//
//  ExchangeViewModel.swift
//  Portal
//
//  Created by Farid on 16.09.2021.
//

import SwiftUI
import Combine
import SocketIO

final class ExchangeViewModel: ObservableObject {
    private let manager: ExchangeManager
    private let maxOrderBookItems = 30
    private let socketURL = URL(string: "https://portalex.herokuapp.com")
    private var socketMannager: SocketManager?
    private var socketClient: SocketIOClient?
    private var subscriptions = Set<AnyCancellable>()
    
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var tradingPairsForSelectedExchange: [TradingPairModel] = []
    @Published private(set) var tradingData: TradingData?
    @Published private(set) var tradingPairBaseIndex: Int = 0
    @Published private(set) var orderBook: SocketOrderBook? = nil
    @Published private(set) var currentPairTicker: SocketTicker = SocketTicker(data: nil, base: String(), quote: String())
        
    @ObservedObject var setup: ExchangeSetupViewModel
    
    @Published var exchangeSelectorState: ExchangeSelectorState = .merged
    @Published var exchangeBalancesSelectorState: BalaceSelectorState = .merged
    @Published var currentPair: TradingPairModel?
    @Published var searchRequest: String = String()
    @Published var showAlert: Bool = false
    @Published var errorMessage: String = String()
    
    var syncedExchanges: [ExchangeModel] {
        manager.syncedExchanges
    }
    var allTraidingPairs: [TradingPairModel] {
        manager.tradingPairs
    }
    
    init(manager: ExchangeManager) {
        self.manager = manager
        self.setup = ExchangeSetupViewModel.config()
        self.isLoggedIn = !syncedExchanges.isEmpty
        self.setDefaultTradingPair()
        self.updateSelectorsState()
        
        $exchangeSelectorState
            .delay(for: .seconds(0.01), scheduler: DispatchQueue.main)
            .sink { [weak self] state in
                self?.onExchangeSelectorStateUpdate(state)
            }
            .store(in: &subscriptions)
        
        $currentPair
            .sink { [weak self] pair in
                guard let tradingPair = pair else { return }
                self?.onTradingPairUpdate(tradingPair)
            }
            .store(in: &subscriptions)
        
        setup
            .$allExchangesSynced
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                if !self.isLoggedIn {
                    self.setDefaultTradingPair()
                    self.updateSelectorsState()
                    self.isLoggedIn = $0
                }
            })
            .store(in: &subscriptions)
        
        manager.fetchOpenOrders()
    }
        
    private func updateSelectorsState() {
        if syncedExchanges.count > 1 {
            exchangeSelectorState = .merged
            exchangeBalancesSelectorState = .merged
        } else {
            if let ex = syncedExchanges.first {
                exchangeSelectorState = .selected(exchange: ex)
                exchangeBalancesSelectorState = .selected(exchange: ex)
            }
        }
    }
    
    private func setDefaultTradingPair() {
        currentPair = allTraidingPairs.compactMap{$0.supported(by: syncedExchanges)}.first
    }
    
    private func onExchangeSelectorStateUpdate(_ state: ExchangeSelectorState) {
        searchRequest = String()
        
        switch state {
        case .merged:
            tradingPairsForSelectedExchange = allTraidingPairs.compactMap{$0.supported(by: syncedExchanges)}
            
            currentPair = tradingPairsForSelectedExchange
                .sorted{$0.change > $1.change}
                .first
        case .selected(let exchange):
            tradingPairsForSelectedExchange = allTraidingPairs.compactMap{$0.supported(by: [exchange])}
            
            currentPair = tradingPairsForSelectedExchange
                .sorted{$0.change > $1.change}
                .first
        }
    }
    
    private func onTradingPairUpdate(_ tradingPair: TradingPairModel) {
        orderBook = nil
        
        tradingData = TradingData(
            exchangeSelectorState: exchangeSelectorState,
            exchanges: syncedExchanges,
            supportedByExchanges: tradingPair.exchange,
            pairs: [tradingPair],
            currentPair: tradingPair
        )
        
        updateSocket()
    }
    
    private func socketParamas() -> [String : Any]? {
        guard
            let td = tradingData,
            let exchangeName = td.exchange?.id.lowercased(),
            let exchangeInfo = td.currentPair.exchanger(exchangeName)
        else {
            return nil
        }
        
        let sym = exchangeInfo.sym
        let symbol = td.currentPair.symbol
        let base = td.currentPair.base
        let quote = td.currentPair.quote
                
        let params = ["ex": exchangeName, "symbol": symbol, "base": base, "quote": quote, "id": sym]
        
        return params
    }
    
    private func updateSocket() {
        resetSocketIfNeeded()

        guard let url = socketURL, let params = socketParamas() else { return }

        socketMannager = SocketManager(
            socketURL: url,
            config: [.connectParams(params),
                     .log(false),
                     .forceNew(true),
                     .reconnects(true),
                     .reconnectAttempts(10)]
        )
        socketClient = socketMannager?.defaultSocket
        
        socketClient?.on(clientEvent: .connect) { [weak self] data, ack in
            print("socket connected")
            
            self?.socketClient?.on("ticker") { [weak self] data, ack in
                guard let self = self, let tickerDict = data[0] as? NSDictionary else { return }
                let ticker = SocketTicker.init(data: tickerDict, base: self.currentPair?.base, quote: self.currentPair?.quote)
                
                if self.currentPairTicker != ticker && !self.showAlert {
                    self.currentPairTicker = ticker
                }
            }

            self?.socketClient?.on("orderbook") { [weak self] data, ack in
                guard let orderBookData = data[0] as? NSDictionary else { return }
                self?.onOrderBookUpdate(orderBookData)
            }
        }
        
        socketClient?.connect()
    }
    
    private func resetSocketIfNeeded() {
        guard socketClient != nil else { return }
        
        socketClient?.emit("end")
        socketClient?.disconnect()
        socketClient = nil
            
        print("socket disconnected")
        orderBook = nil
    }
    
    private func onOrderBookUpdate(_ book: NSDictionary) {
        guard !showAlert else { return }
        
        let newOrderBook = SocketOrderBook(tradingPair: currentPair, data: book)
        let firstIndex = 0
        
        if newOrderBook.tradingPair == currentPair, var updatedBook = orderBook {
            updatedBook.bids.insert(contentsOf: newOrderBook.bids, at: firstIndex)
            
            if updatedBook.bids.count > maxOrderBookItems {
                updatedBook.bids.removeLast(maxOrderBookItems/2)
            }
            
            updatedBook.asks.insert(contentsOf: newOrderBook.asks, at: firstIndex)
            
            if updatedBook.asks.count > maxOrderBookItems {
                updatedBook.asks.removeLast(maxOrderBookItems/2)
            }
            
            orderBook = updatedBook
        } else {
            orderBook = newOrderBook
        }
    }
    
    func placeOrder(type: OrderType, side: OrderSide, amount: String, price: String) {
        guard let td = tradingData else { return }
        
        guard !amount.isEmpty else {
            errorMessage = "Invalid amount"
            showAlert = true
            return
        }

        if type == .limit, price.isEmpty {
            errorMessage = "Invalid price"
            showAlert = true
            return
        }
        
        manager
            .placeOrder(tradingData: td, type: type, side: side, amount: amount, price: price)?
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.errorMessage = error.description
                        self?.showAlert = true
                    }
                case .finished:
                    self?.manager.updateBalances()
                    self?.manager.fetchOpenOrders()
                }
            }, receiveValue: { _ in })
            .store(in: &subscriptions)
    }
}

extension ExchangeViewModel {
    static func config() -> ExchangeViewModel {
        let manager = Portal.shared.exchangeManager
        return ExchangeViewModel(manager: manager)
    }
}
