//
//  TxsViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Foundation
import BitcoinCore
import Combine
import Coinpaprika

final class TxsViewModel: ObservableObject {
    let coin: Coin
    
    private var allTxs: [TransactionRecord] = [] {
        didSet {
            updateTxList()
        }
    }
    
    @Published private(set) var txs: [TransactionRecord] = []
    @Published var txSortState: TxSortState = .all
    var lastBlockInfo: LastBlockInfo?
    
    private var transactionAdapter: ITransactionsAdapter
    private var balance: Decimal
    private let currency: Currency
    private var ticker: Ticker?
    private var subscriptions = Set<AnyCancellable>()
    
    var balanceString: String {
        let coinBalance = "\(balance) \(coin.code)"
        let balanceString: String
        
        if let ticker = ticker {
            switch currency {
            case .btc:
                balanceString = "\(coinBalance) (\(currency.symbol)" + "\((balance * ticker[.btc].price).rounded(toPlaces: 2)) \(currency.code))"
            case .eth:
                balanceString = "\(coinBalance) (\(currency.symbol)" + "\((balance * ticker[.eth].price).rounded(toPlaces: 2)) \(currency.code))"
            case .fiat(let fiatCurrency):
                balanceString = "\(coinBalance) (\(fiatCurrency.symbol)" + "\((balance * ticker[.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2)) \(fiatCurrency.code))"
            }
        } else {
            balanceString = coinBalance
        }
        
        return balanceString
    }
    
    init(coin: Coin, balance: Decimal, transactionAdapter: ITransactionsAdapter, currency: Currency, ticker: Ticker?) {
        self.coin = coin
        self.balance = balance
        self.transactionAdapter = transactionAdapter
        self.currency = currency
        self.ticker = ticker
        self.lastBlockInfo = transactionAdapter.lastBlockInfo
        
        $txSortState
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.updateTxList()
            }
            .store(in: &subscriptions)
        
        transactionAdapter.transactionRecords
            .receive(on: RunLoop.main)
            .sink { [weak self] records in
                self?.allTxs = records
            }
            .store(in: &subscriptions)
        
        transactionAdapter.transactions(from: nil, limit: 100)
            .receive(on: RunLoop.main)
            .sink { [weak self] records in
                self?.allTxs = records
            }
            .store(in: &subscriptions)
    }
    
    func title(tx: TransactionRecord) -> String {
        switch tx.type {
        case .incoming:
            return "Received \(tx.amount.double.rounded(toPlaces: 6).toString()) \(coin.code)"
        case .outgoing:
            return "Sent \(tx.amount.double.rounded(toPlaces: 6).toString()) \(coin.code)"
        case .sentToSelf:
            return "Send to self \(tx.amount.double.rounded(toPlaces: 6).toString()) \(coin.code)"
        case .approve:
            return "Approving... \(tx.amount.double.rounded(toPlaces: 6).toString()) \(coin.code)"
        case .transfer:
            return "Trasfer... \(tx.amount.double.rounded(toPlaces: 6).toString()) \(coin.code)"
        }
    }
    
    func date(tx: TransactionRecord) -> String {
        tx.date.timeAgoSinceDate(shortFormat: true)
    }
    
    func confimations(tx: TransactionRecord) -> String {
        "\(tx.confirmations(lastBlockHeight: transactionAdapter.lastBlockInfo?.height)) confirmations"
    }
    
    func updateTxList() {
        switch txSortState {
        case .all:
            txs = allTxs
        case .sent:
            txs = allTxs.filter{ $0.type == .outgoing }
        case .received:
            txs = allTxs.filter{ $0.type == .incoming }
        case .swapped:
            txs = []
        }
    }
    
    deinit {
//        print("Tx view Model deinited")
    }
}

extension TxsViewModel {
    static func config(coin: Coin) -> TxsViewModel? {
        let walletManager: IWalletManager = Portal.shared.walletManager
        let adapterManager: IAdapterManager = Portal.shared.adapterManager
        let currency = Portal.shared.state.wallet.currency
        let ticker = Portal.shared.marketDataProvider.ticker(coin: coin)
        
        guard
            let wallet = walletManager.activeWallets.first(where: { $0.coin == coin }),
            let balanceAdapter = adapterManager.balanceAdapter(for: wallet),
            let transactionAdapter = adapterManager.transactionsAdapter(for: wallet)
        else {
            return nil
        }
        
        return TxsViewModel(
            coin: coin,
            balance: balanceAdapter.balance,
            transactionAdapter: transactionAdapter,
            currency: currency,
            ticker: ticker
        )
    }
}
