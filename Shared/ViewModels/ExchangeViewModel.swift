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
    let syncedExchanges: [ExchangeModel]
    let allTraidingPairs: [TradingPairModel]
    
    private let socketURL = URL(string: "https://portalex.herokuapp.com")
    private var socketMannager: SocketManager?
    private var socketClient: SocketIOClient?
    
    @ObservedObject var setup: ExchangeSetupViewModel
    
    @Published var exchangeSelectorState: ExchangeSelectorState = .merged
    @Published var currentPair: TradingPairModel?
    @Published var searchRequest: String = String()
    
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var tradingPairsForSelectedExchange: [TradingPairModel] = []
    @Published private(set) var tradingData: TradingData?
    @Published private(set) var tradingPairBaseIndex: Int = 0
    @Published private(set) var orderBook: SocketOrderBook? = nil
    @Published private(set) var currentPairTicker: SocketTicker = SocketTicker(data: nil, base: String(), quote: String())
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(exchanges: [ExchangeModel], tradingPairs: [TradingPairModel]) {
        self.setup = ExchangeSetupViewModel.config()
        
        self.syncedExchanges = exchanges
        self.allTraidingPairs = tradingPairs
        self.currentPair = allTraidingPairs.compactMap{$0.supported(by: syncedExchanges)}.first
        
        if exchanges.count > 1 {
            exchangeSelectorState = .merged
        } else {
            if let ex = exchanges.first {
                exchangeSelectorState = .selected(exchange: ex)
            }
        }
        
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
            
            self?.socketClient?.on("ticker") { data, ack in
                guard let tickerDict = data[0] as? NSDictionary else { return }
                self?.currentPairTicker = SocketTicker.init(data: tickerDict, base: self?.currentPair?.base, quote: self?.currentPair?.quote)
            }

            self?.socketClient?.on("orderbook") { [weak self] data, ack in
                guard let orderBookData = data[0] as? NSDictionary else { return }
                self?.onOrderBookUpdate(orderBookData)
            }
        }
        
//        socketClient?.on(clientEvent: .disconnect) { [weak self] data, ack in
//            print("socket diiiiiisconnected")
//        }

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
        let newOrderBook = SocketOrderBook(tradingPair: currentPair, data: book)
        
        if newOrderBook.tradingPair == currentPair, var updatedBook = orderBook {
            updatedBook.bids.insert(contentsOf: newOrderBook.bids, at: 0)
            
            if updatedBook.bids.count > 30 {
                updatedBook.bids.removeLast(10)
            }
            
            updatedBook.asks.insert(contentsOf: newOrderBook.asks, at: 0)
            
            if updatedBook.asks.count > 30 {
                updatedBook.asks.removeLast(10)
            }
            
            orderBook = updatedBook
        } else {
            orderBook = newOrderBook
        }
    }
}

extension ExchangeViewModel {
    static func config() -> ExchangeViewModel {
        let manager = Portal.shared.exchangeManager
        let exchanges = manager.exchanges
        let tradingPairs = manager.traidingPairs
        
        return ExchangeViewModel(exchanges: exchanges, tradingPairs: tradingPairs)
    }
}
