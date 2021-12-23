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
import EthereumKit
import BigInt

final class SendAssetViewModel: ObservableObject {
    @Published private var amount: Decimal = 0
    
    @Published var receiverAddress = String()
    @Published var memo = String()
    @Published var amountIsValid: Bool = true
    @Published var txFeePriority: FeeRatePriority = .medium
    
    @Published private(set) var txFee = String()
    @Published private(set) var addressIsValid: Bool = true
    @Published private(set) var canSend: Bool = false
    @Published private(set) var balanceString: String = String()
    @Published private(set) var transactions: [TransactionRecord] = []
    @Published private(set) var lastBlockInfo: LastBlockInfo?
    
    @Published private var feeRate: Int = 1 //medium
    
    @ObservedObject private(set) var exchangerViewModel: ExchangerViewModel
    
    let coin: Coin
    private let balanceAdapter: IBalanceAdapter
    private let txsAdapter: ITransactionsAdapter
    private let sendBtcAdapter: ISendBitcoinAdapter?
    private let sendEthAdapter: ISendEthereumAdapter?
    private let feeRateProvider: IFeeRateProvider
    private let currency: Currency
    private var ticker: Ticker?
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(
        coin: Coin,
        balanceAdapter: IBalanceAdapter,
        txsAdapter: ITransactionsAdapter,
        feeRateProvider: IFeeRateProvider,
        sendBitcoinAdapter: ISendBitcoinAdapter?,
        sendEtherAdapter: ISendEthereumAdapter?,
        currency: Currency,
        ticker: Ticker?
    ) {
        
        self.coin = coin
        self.sendEthAdapter = sendEtherAdapter
        self.sendBtcAdapter = sendBitcoinAdapter
        self.balanceAdapter = balanceAdapter
        self.txsAdapter = txsAdapter
        self.feeRateProvider = feeRateProvider
        self.ticker = ticker
        self.lastBlockInfo = txsAdapter.lastBlockInfo
        
        self.exchangerViewModel = .init(coin: coin, currency: currency)
        self.currency = currency
        
        updateBalance()
        
        exchangerViewModel.$assetValue
            .receive(on: RunLoop.main)
            .compactMap { Decimal(string: $0) }
            .assign(to: \.amount, on: self)
            .store(in: &subscriptions)
        
        $txFeePriority
            .flatMap { priority in
                self.feeRateProvider.feeRate(priority: priority)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] feeRate in
                self?.feeRate = feeRate
            }
            .store(in: &subscriptions)
        
        Publishers.CombineLatest3($amount, $receiverAddress, $feeRate)
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
    }
    
    deinit {
//        print("send asset view model deinited")
    }
    
    private func validate(address: String, amount: Decimal) {
        let fee = self.fee(amount: amount, address: address)
        
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
                let gasPrice = feeRate
                let gasLimit = 21000
                let etherTxFee = gasPrice * gasLimit / 1_000_000_000
                
                switch currency {
                case .fiat(let fiatCurrency):
                    txFee = "\(etherTxFee) \(coin.code) (\((Decimal(etherTxFee) * price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2)) \(fiatCurrency.code))"
                case .btc, .eth:
                    let usd: FiatCurrency = USD
                    txFee = "\(etherTxFee) \(coin.code) (\((Decimal(etherTxFee) * price * Decimal(usd.rate)).rounded(toPlaces: 2)) \(usd.code))"
                }
            }
        } else {
            txFee = String()
        }
        
        do {
            try validate(address: self.receiverAddress)
            
            addressIsValid = true
        } catch {
            addressIsValid = false
        }
                        
        if addressIsValid {
            amountIsValid = amount <= availableBalance(address: address)
        } else {
            let avaliableBalance = balanceAdapter.balance
            amountIsValid = amount <= avaliableBalance
        }

        if receiverAddress.isEmpty {
            addressIsValid = true
            canSend = false
        } else {
            let avaliableBalance = availableBalance(address: address)
            canSend = addressIsValid && (amount > 0 && amount <= avaliableBalance)
        }
    }
    
    private func validate(address: String) throws {
        switch coin.type {
        case .bitcoin:
            try sendBtcAdapter?.validate(address: address, pluginData: [:])
        case .ethereum, .erc20( _):
            _ = try EthereumKit.Address.init(hex: address)
        }
    }
    
    private func fee(amount: Decimal, address: String?) -> Decimal {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.fee(amount: amount, feeRate: feeRate, address: address, pluginData: [:]) ?? 0
        case .ethereum:
            return 0
        case .erc20( _):
            return 0
        }
    }
    
    private func availableBalance(address: String?) -> Decimal {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.availableBalance(feeRate: feeRate, address: address, pluginData: [:]) ?? 0
        case .ethereum:
            return sendEthAdapter?.balance ?? 0
        case .erc20( _):
            return balanceAdapter.balance
        }
    }
    
    private func updateBalance() {
        let balance = balanceAdapter.balance
        
        if let ticker = ticker {
            switch currency {
            case .btc:
                balanceString = "\(balance) \(coin.code) (\(currency.symbol)" + "\((balance * ticker[.btc].price).rounded(toPlaces: 2)) \(currency.code))"
            case .eth:
                balanceString = "\(balance) \(coin.code) (\(currency.symbol)" + "\((balance * ticker[.eth].price).rounded(toPlaces: 2)) \(currency.code))"
            case .fiat(let fiatCurrency):
                balanceString = "\(balance) \(coin.code) (\(fiatCurrency.symbol)" + "\((balance * ticker[.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2)) \(fiatCurrency.code))"
            }
        } else {
            balanceString = "\(balance) \(coin.code)"
        }
    }
    
    func send() {
        switch coin.type {
        case .bitcoin:
            sendBtcAdapter?.send(amount: amount, address: receiverAddress, feeRate: feeRate, pluginData: [:], sortMode: .shuffle)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    
                }, receiveValue: { [weak self] _ in
                    print("Btc tx sent")
                    self?.reset()
                })
                .store(in: &subscriptions)
        case .ethereum:
            guard
                let amountToSend = BigUInt(amount.roundedString(decimal: coin.decimal)),
                let recepientAddress = try? Address(hex: receiverAddress),
                let provider = sendEthAdapter
            else {
                return
            }
                        
            Portal.shared.feeRateProvider.ethereumGasPrice.sink { gasPrice in
                provider.send(address: recepientAddress, value: amountToSend, transactionInput: Data(), gasPrice: gasPrice, gasLimit: 21000, nonce: nil)
                    .receive(on: RunLoop.main)
                    .sink { completion in
                        if case let .failure(error) = completion {
                            print("Sending ether error: \(error.localizedDescription)")
                        }
                    } receiveValue: { [weak self] transaction in
                        print(transaction.transaction.hash.hex)
                        self?.reset()
                    }
                    .store(in: &self.subscriptions)
            }
            .store(in: &subscriptions)
        case .erc20(_ ):
            guard
                let amountToSend = BigUInt(amount.roundedString(decimal: coin.decimal)),
                let recepientAddress = try? Address(hex: receiverAddress),
                let provider = sendEthAdapter
            else {
                return
            }
            
            let transactionData = provider.transactionData(amount: amountToSend, address: recepientAddress)
            
//
        }
    }
    
    private func reset() {
        DispatchQueue.main.async {
            self.amount = 0
            self.receiverAddress = String()
            self.memo = String()
            
            self.updateBalance()
            
            self.exchangerViewModel.reset()
        }
    }
}

extension SendAssetViewModel {
    static func config(coin: Coin, currency: Currency) -> SendAssetViewModel? {
        let walletManager = Portal.shared.walletManager
        let adapterManager = Portal.shared.adapterManager
        let feeRateProvider = Portal.shared.feeRateProvider
        let mdProvider = Portal.shared.marketDataProvider
        
        guard
            let wallet = walletManager.activeWallets.first(where: { $0.coin == coin }),
            let balanceAdapter = adapterManager.balanceAdapter(for: wallet),
            let transactionAdapter = adapterManager.transactionsAdapter(for: wallet)
        else {
            return nil
        }
        
        let ticker = mdProvider.ticker(coin: coin)
        
        switch coin.type {
        case .bitcoin:
            let sendBTCAdapter = adapterManager.adapter(for: coin) as? ISendBitcoinAdapter
            let feesProvider = BitcoinFeeRateProvider(feeRateProvider: feeRateProvider)
            
            return SendAssetViewModel(
                coin: coin,
                balanceAdapter: balanceAdapter,
                txsAdapter: transactionAdapter,
                feeRateProvider: feesProvider,
                sendBitcoinAdapter: sendBTCAdapter,
                sendEtherAdapter: nil,
                currency: currency,
                ticker: ticker
            )
            
        case .ethereum, .erc20(address: _):
            let sendEtherAdapter = adapterManager.adapter(for: coin) as? ISendEthereumAdapter
            let feesProvider = EthereumFeeRateProvider(feeRateProvider: feeRateProvider)
            
            return SendAssetViewModel(
                coin: coin,
                balanceAdapter: balanceAdapter,
                txsAdapter: transactionAdapter,
                feeRateProvider: feesProvider,
                sendBitcoinAdapter: nil,
                sendEtherAdapter: sendEtherAdapter,
                currency: currency,
                ticker: ticker
            )
        }
    }
}
