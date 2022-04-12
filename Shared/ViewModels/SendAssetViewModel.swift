//
//  SendAssetViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Foundation
import SwiftUI
import Combine
import Coinpaprika

final class SendAssetViewModel: ObservableObject {
    enum SendAssetStep: Int, Comparable {
        static func < (lhs: SendAssetViewModel.SendAssetStep, rhs: SendAssetViewModel.SendAssetStep) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
        case recipient = 0, amount, summary, sent
    }
    
    @Published var step: SendAssetStep = .recipient
    @Published var memo = String()
    @Published var amountIsValid: Bool = true
    @Published var isSendingMax: Bool = false
    @Published var txFeePriority: FeeRatePriority = .medium
    
    @Published private(set) var txFee = String()
    @Published private(set) var addressIsValid: Bool = true
    @Published private(set) var balanceString: String = String()
    @Published private(set) var transactions: [TransactionRecord] = []
    @Published private(set) var lastBlockInfo: LastBlockInfo?
    @Published private(set) var actionButtonEnabled: Bool  = false
    
    @Published var receiverAddress = String() {
        didSet {
            sendService.receiverAddress.send(receiverAddress)
        }
    }
    
    @Published private(set) var amount: Decimal = 0 {
        didSet {
            sendService.amount.send(amount)
        }
    }
        
    @ObservedObject private(set) var exchangerViewModel: ExchangerViewModel
    
    let coin: Coin
    private let txsAdapter: ITransactionsAdapter
    private let sendService: ISendAssetService
    private let currency: Currency
    private var ticker: Ticker?
    private(set) var sendError: Error?
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(
        coin: Coin,
        txsAdapter: ITransactionsAdapter,
        sendService: ISendAssetService,
        currency: Currency,
        ticker: Ticker?
    ) {
        
        self.coin = coin
        self.sendService = sendService
        self.txsAdapter = txsAdapter
        self.ticker = ticker
        self.lastBlockInfo = txsAdapter.lastBlockInfo
        
        self.exchangerViewModel = .init(coin: coin, currency: currency, ticker: ticker)
        self.currency = currency
        
        updateBalance()
        
        exchangerViewModel.$assetValue
            .receive(on: RunLoop.main)
            .compactMap { Decimal(string: $0) }
            .assign(to: \.amount, on: self)
            .store(in: &subscriptions)
        
        $txFeePriority
            .flatMap { priority in
                self.sendService.feeRateProvider.feeRate(priority: priority)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] feeRate in
                guard let self = self else { return }
                
                self.sendService.feeRate.send(feeRate)
                
                if self.isSendingMax {
                    self.exchangerViewModel.assetValue = self.sendService.spendable.string
                }
            }
            .store(in: &subscriptions)
        
        Publishers.CombineLatest3(sendService.amount, sendService.receiverAddress, sendService.feeRate)
            .receive(on: RunLoop.main)
            .sink { [weak self] (amount, address, rate) in
                guard !address.isEmpty else { return }
                self?.validate(address: address, amount: amount)
            }
            .store(in: &subscriptions)
        
        txsAdapter.transactionRecords
            .receive(on: RunLoop.main)
            .sink { [weak self] records in
                guard let self = self else { return }
                let updatedTxs = records.filter{ !self.transactions.contains($0) }
                self.transactions.append(contentsOf: updatedTxs.filter{ $0.type != .incoming })
            }
            .store(in: &subscriptions)

        txsAdapter.transactions(from: nil, limit: 100)
            .receive(on: RunLoop.main)
            .sink { [weak self] records in
                self?.transactions = records.filter{ $0.type != .incoming }
            }
            .store(in: &subscriptions)
        
        $step.receive(on: RunLoop.main)
            .sink { [weak self] newStep in
            guard let self = self else { return }
            switch newStep {
            case .recipient:
                self.actionButtonEnabled = !self.sendService.receiverAddress.value.isEmpty && self.addressIsValid
            case .amount:
                self.validate(
                    address: self.sendService.receiverAddress.value,
                    amount: self.sendService.amount.value
                )
            case .summary:
                self.actionButtonEnabled = true
            case .sent:
                self.actionButtonEnabled = false
            }
        }
        .store(in: &subscriptions)
        
        $isSendingMax
            .dropFirst()
            .sink { [weak self] sendMax in
                if sendMax {
                    self?.exchangerViewModel.assetValue = self?.sendService.spendable.string ?? String()
                }
            }
            .store(in: &subscriptions)
    }
    
    deinit {
//        print("send asset view model deinited")
    }
    
    private func validate(address: String, amount: Decimal) {
        switch step {
        case .recipient:
            do {
                try sendService.validateAddress()
                addressIsValid = true
            } catch {
                addressIsValid = false
            }
            
            actionButtonEnabled = addressIsValid && !sendService.receiverAddress.value.isEmpty
        case .amount:
            let fee = sendService.fee

            if fee > 0 {
                let price = ticker?[.usd].price ?? 1

                switch coin.type {
                case .bitcoin:
                    switch currency {
                    case .fiat(let fiatCurrency):
                        txFee = "\(fee) \(coin.code) (\((fee * price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2)) \(fiatCurrency.code))"
                    case .btc, .eth:
                        let usd: FiatCurrency = USD
                        txFee = "\(fee) \(coin.code) (\((fee * price * Decimal(usd.rate)).rounded(toPlaces: 2)) \(usd.code))"
                    }
                default:
                    switch currency {
                    case .fiat(let fiatCurrency):
                        txFee = "\(fee.rounded(toPlaces: 8)) \(coin.code) (\((fee * price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2)) \(fiatCurrency.code))"
                    case .btc, .eth:
                        let usd: FiatCurrency = USD
                        txFee = "\(fee.rounded(toPlaces: 8)) \(coin.code) (\((fee * price * Decimal(usd.rate)).rounded(toPlaces: 2)) \(usd.code))"
                    }
                }
            }
                            
            if addressIsValid {
                amountIsValid = amount <= sendService.spendable
            } else {
                amountIsValid = amount <= sendService.balance
            }

            if sendService.receiverAddress.value.isEmpty {
                addressIsValid = true
                actionButtonEnabled = false
            } else {
                actionButtonEnabled = addressIsValid && (amount > 0 && amount <= sendService.spendable)
            }
        case .summary, .sent:
            break
        }
    }
        
    private func updateBalance() {
        let balance = sendService.balance
        let coinBalance = "\(balance) \(coin.code)"
        
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
    }
    
    func send() {
        actionButtonEnabled = false
                
        sendService.send()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.sendError = error
                    self?.step = .sent
                    print("Sending asset error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] _ in
                self?.step = .sent
            })
            .store(in: &subscriptions)
    }
    
    func goBack() {
        withAnimation(.easeInOut(duration: 0.2)) {
            switch step {
            case .recipient:
                break
            case .amount:
                step = .recipient
            case .summary:
                isSendingMax = false
                exchangerViewModel.assetValue = String()
                step = .amount
            case .sent:
                step = .summary
            }
        }
    }
    
    func close() {
        Portal.shared.state.modalView = .none
    }
    
    func resetErrorState() {
        sendError = nil
        actionButtonEnabled = true
    }
}

extension SendAssetViewModel {
    static func config(coin: Coin, currency: Currency) -> SendAssetViewModel? {
        let walletManager = Portal.shared.walletManager
        let adapterManager = Portal.shared.adapterManager
        let feeRateProvider = Portal.shared.feeRateProvider
        let mdProvider = Portal.shared.marketDataProvider
        let ticker = mdProvider.ticker(coin: coin)
        
        guard
            let wallet = walletManager.activeWallets.first(where: { $0.coin == coin }),
            let adapter = adapterManager.adapter(for: coin),
            let balanceAdapter = adapter as? IBalanceAdapter,
            let transactionAdapter = adapterManager.transactionsAdapter(for: wallet)
        else {
            return nil
        }
                
        switch coin.type {
        case .bitcoin:
            let feesProvider = BitcoinFeeRateProvider(feeRateProvider: feeRateProvider)
    
            guard let sendAdapter = adapter as? ISendBitcoinAdapter else { return nil }
            
            let service = SendBTCService(balanceAdapter: balanceAdapter, sendAdapter: sendAdapter, feeRateProvider: feesProvider)
            
            return SendAssetViewModel(
                coin: coin,
                txsAdapter: transactionAdapter,
                sendService: service,
                currency: currency,
                ticker: ticker
            )
        case .ethereum, .erc20(address: _):
            let ethereumManager = Portal.shared.ethereumKitManager
            let feesProvider = EthereumFeeRateProvider(feeRateProvider: feeRateProvider)
            
            guard let sendAdapter = adapter as? ISendEthereumAdapter else { return nil }
            
            let service = SendETHService(coin: coin, balanceAdapter: balanceAdapter, sendAdapter: sendAdapter, feeRateProvider: feesProvider, manager: ethereumManager)
            
            return SendAssetViewModel(
                coin: coin,
                txsAdapter: transactionAdapter,
                sendService: service,
                currency: currency,
                ticker: ticker
            )
        }
    }
}
