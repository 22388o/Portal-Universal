//
//  SendAssetViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Foundation
import SwiftUI
import Combine
import RxSwift
import Coinpaprika
import EthereumKit
import BigInt

final class SendAssetViewModel: ObservableObject {
    @Published private var amount: Decimal = 0
    
    @Published var receiverAddress = String()
    @Published var memo = String()
    @Published var amountIsValid: Bool = true
    
    @Published private(set) var txFee = String()
    @Published private(set) var addressIsValid: Bool = true
    @Published private(set) var canSend: Bool = false
    @Published private(set) var balanceString: String = String()
    @Published private(set) var transactions: [TransactionRecord] = []
    @Published private(set) var lastBlockInfo: LastBlockInfo?
    
    @ObservedObject private(set) var exchangerViewModel: ExchangerViewModel
    
    let coin: Coin
    private let balanceAdapter: IBalanceAdapter
    private let txsAdapter: ITransactionsAdapter
    private let sendBtcAdapter: ISendBitcoinAdapter?
    private let sendEthAdapter: ISendEthereumAdapter?
    private let feeRateProvider: IFeeRateProvider
    private let fiatCurrency: FiatCurrency
    private var ticker: Ticker?
    private var feeRate: Int = 8 //medium
    
    private var cancellable = Set<AnyCancellable>()
    private let disposeBag = DisposeBag()
    
    init(
        coin: Coin,
        balanceAdapter: IBalanceAdapter,
        txsAdapter: ITransactionsAdapter,
        feeRateProvider: IFeeRateProvider,
        sendBitcoinAdapter: ISendBitcoinAdapter?,
        sendEtherAdapter: ISendEthereumAdapter?,
        fiatCurrency: FiatCurrency,
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
        
        self.exchangerViewModel = .init(coin: coin, fiat: fiatCurrency)
        
        self.fiatCurrency = fiatCurrency
        
        updateBalance()
        
        exchangerViewModel.$assetValue
            .receive(on: RunLoop.main)
            .compactMap { Decimal(string: $0) }
            .assign(to: \.amount, on: self)
            .store(in: &cancellable)
        
        feeRateProvider.feeRate(priority: .high)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] feeRate in
                self?.feeRate = feeRate
            }, onError: { error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        Publishers.CombineLatest($amount, $receiverAddress)
            .receive(on: RunLoop.main)
            .sink { [weak self] (amount, address) in
                self?.validate(address: address, amount: amount)
            }
            .store(in: &cancellable)
        
        txsAdapter.transactionRecordsObservable
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] records in
                self?.transactions.append(contentsOf: records.filter{ $0.type != .incoming })
            })
            .disposed(by: disposeBag)
        
        txsAdapter.transactionsSingle(from: nil, limit: 100)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] records in
                self?.transactions = records.filter{ $0.type != .incoming }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("send asset view model deinited")
    }
    
    private func validate(address: String, amount: Decimal) {
        let fee = self.fee(amount: amount, address: address)
        
        if fee > 0 {
            switch coin.type {
            case .bitcoin:
                txFee = "\(fee) \(coin.code) (\((fee * ticker![.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2)) \(fiatCurrency.code)) tx fee - Fast Speed"
            default:
                let gasPrice = feeRate
                let gasLimit = 21000
                let etherTxFee = gasPrice * gasLimit / 1_000_000_000
                
                txFee = "\(etherTxFee) \(coin.code) (\((Decimal(etherTxFee) * ticker![.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2)) \(fiatCurrency.code)) tx fee - Fast Speed"
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
            balanceString = "\(balance) \(coin.code) (\(fiatCurrency.symbol)" + "\((balance * ticker[.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2)) \(fiatCurrency.code))"
        } else {
            balanceString = "\(balance) \(coin.code)"
        }
    }
    
    func send() {
        switch coin.type {
        case .bitcoin:
            sendBtcAdapter?
                .sendSingle(amount: amount, address: receiverAddress, feeRate: feeRate, pluginData: [:], sortMode: .shuffle)
                .subscribe(onSuccess: { [weak self] _ in
                    print("Btc tx sent")
                    self?.reset()
                }, onError: { error in
                    print("Sending btc error: \(error.localizedDescription)")
                })
                .disposed(by: disposeBag)
        case .ethereum:
            guard
                let amountToSend = BigUInt(amount.roundedString(decimal: coin.decimal)),
                let recepientAddress = try? Address(hex: receiverAddress),
                let provider = sendEthAdapter
            else {
                return
            }
            
            Portal.shared.feeRateProvider.ethereumGasPrice
                .flatMap { gasPrice in
                    return provider.evmKit.sendSingle(address: recepientAddress, value: amountToSend, gasPrice: gasPrice, gasLimit: 21000)
                }
                .subscribe(onSuccess: { [weak self] transaction in
                    print(transaction.transaction.hash.hex)
                    self?.reset()
                }, onError: { error in
                    print("Sending ether error: \(error.localizedDescription)")
                })
                .disposed(by: disposeBag)
        case .erc20(_ ):
            guard
                let amountToSend = BigUInt(amount.roundedString(decimal: coin.decimal)),
                let recepientAddress = try? Address(hex: receiverAddress),
                let provider = sendEthAdapter
            else {
                return
            }
            
            let transactionData = provider.transactionData(amount: amountToSend, address: recepientAddress)
            
            Portal.shared.feeRateProvider.ethereumGasPrice
                .flatMap { gasPrice in
                    return provider.evmKit.sendSingle(transactionData: transactionData, gasPrice: gasPrice, gasLimit: 21000)
                }
                .subscribe(onSuccess: { transaction in
                    print(transaction.transaction.hash.hex)
                }, onError: { error in
                    print("Sending erc20 error: \(error)")
                })
                .disposed(by: disposeBag)
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
    static func config(coin: Coin, fiatCurrency: FiatCurrency) -> SendAssetViewModel? {
        let walletManager: IWalletManager = Portal.shared.walletManager
        let adapterManager: IAdapterManager = Portal.shared.adapterManager
        let feeProvider: FeeRateProvider = Portal.shared.feeRateProvider
        let mdProvider: MarketDataProvider = Portal.shared.marketDataProvider
        
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
            let feesProvider = BitcoinFeeRateProvider(feeRateProvider: feeProvider)
            
            return SendAssetViewModel(
                coin: coin,
                balanceAdapter: balanceAdapter,
                txsAdapter: transactionAdapter,
                feeRateProvider: feesProvider,
                sendBitcoinAdapter: sendBTCAdapter,
                sendEtherAdapter: nil,
                fiatCurrency: fiatCurrency,
                ticker: ticker
            )
            
        case .ethereum, .erc20(address: _):
            let sendEtherAdapter = adapterManager.adapter(for: coin) as? ISendEthereumAdapter
            let feesProvider = EthereumFeeRateProvider(feeRateProvider: feeProvider)
            
            return SendAssetViewModel(
                coin: coin,
                balanceAdapter: balanceAdapter,
                txsAdapter: transactionAdapter,
                feeRateProvider: feesProvider,
                sendBitcoinAdapter: nil,
                sendEtherAdapter: sendEtherAdapter,
                fiatCurrency: fiatCurrency,
                ticker: ticker
            )
        }
    }
}
