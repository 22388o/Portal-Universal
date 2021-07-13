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
    
    @ObservedObject var exchangerViewModel: ExchangerViewModel
    
    let asset: IAsset
    private let wallet: IWallet
    private let fiatCurrency: FiatCurrency
    
    private var cancellable = Set<AnyCancellable>()
    private let disposeBag = DisposeBag()
    
    init(wallet: IWallet, asset: IAsset, fiatCurrency: FiatCurrency) {
        print("send asset view model inited")
        self.wallet = wallet
        self.asset = asset
        self.exchangerViewModel = .init(asset: asset, fiat: fiatCurrency)
        self.fiatCurrency = fiatCurrency
        
        updateBalance()
        
        exchangerViewModel.$assetValue
            .receive(on: RunLoop.main)
            .compactMap { Decimal(string: $0) }
            .assign(to: \.amount, on: self)
            .store(in: &cancellable)
        
        Publishers.CombineLatest($amount, $receiverAddress)
            .receive(on: RunLoop.main)
            .sink { [weak self] (amount, address) in
                guard let self = self else { return }
                
                let fee = asset.fee(amount: amount, feeRate: 4, address: address)
                
                if fee > 0 {
                    self.txFee = "\(fee) \(asset.coin.code) (\((fee * asset.marketDataProvider.ticker![.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2)) \(fiatCurrency.code)) tx fee - Fast Speed"
                } else {
                    self.txFee = String()
                }
                
                do {
                    try asset.validate(address: self.receiverAddress)
                    self.addressIsValid = true
                } catch {
                    self.addressIsValid = false
                }
                                
                if self.addressIsValid {
                    self.amountIsValid = amount <= asset.availableBalance(feeRate: 4, address: self.receiverAddress)
                } else {
                    let avaliableBalance = asset.balanceAdapter?.balance ?? 0
                    self.amountIsValid = amount <= avaliableBalance
                }
    
                if self.receiverAddress.isEmpty {
                    self.addressIsValid = true
                    self.canSend = false
                } else {
                    self.canSend = amount > 0 && amount <= asset.availableBalance(feeRate: 4, address: address) && self.addressIsValid
                }
            }
            .store(in: &cancellable)
        
        asset.transactionAdaper?.transactionRecordsObservable
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] records in
                self?.transactions = records.filter{ $0.type != .incoming }
            })
            .disposed(by: disposeBag)
        
        asset.transactionAdaper?.transactionsSingle(from: nil, limit: 100)
            .asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] records in
                self?.transactions = records.filter{ $0.type != .incoming }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("send asset view model deinited")
    }
    
    private func updateBalance() {
        let balance = asset.balanceAdapter?.balance ?? 0
        
        if let ticker = asset.marketDataProvider.ticker {
            balanceString = "\(balance) \(asset.coin.code) (\(fiatCurrency.symbol)" + "\((balance * ticker[.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2)) \(fiatCurrency.code))"
        } else {
            balanceString = "\(balance) \(asset.coin.code)"
        }
    }
    
    func send() {
        asset.send(amount: amount, address: receiverAddress, feeRate: 4, sortMode: .shuffle)
            .sink { error in
                print(error)
            } receiveValue: { _ in
                self.reset()
            }
            .store(in: &cancellable)
    }
    
    private func reset() {
        amount = 0
        receiverAddress = String()
        memo = String()
        
        updateBalance()
        
        exchangerViewModel.reset()
    }
}
