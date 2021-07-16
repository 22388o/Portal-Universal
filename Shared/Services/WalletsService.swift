//
//  WalletsService.swift
//  Portal
//
//  Created by Farid on 14.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import RxSwift

final class WalletsService: ObservableObject {
    enum State {
        case currentWallet, createWallet, restoreWallet
    }
    
    @Published var state: State = .createWallet
    @Published var currentWallet: IWallet?
    
    var wallets: [IWallet]? { _wallets }
    
    private var _wallets: [DBWallet]?
    
    private let localStorage: ILocalStorage
    private let secureStorage: IKeychainStorage
    private let dbStorage: IDBStorage
    private let notificationService: NotificationService
    
    private var disposeBag = DisposeBag()

    init(
        dbStorage: IDBStorage,
        localStorage: ILocalStorage,
        secureStorage: IKeychainStorage,
        notificationService: NotificationService
    ) {
        print("\(#function) init")
        
        self.dbStorage = dbStorage
        self.localStorage = localStorage
        self.secureStorage = secureStorage
        self.notificationService = notificationService
        
        if let walletID = localStorage.getCurrentWalletID() {
            setupWallet(id: walletID)
        }
    }
    
    deinit {
        print("\(#function) deinit")
    }
    
    private func syncWallets() {
        self._wallets = try? dbStorage.fetchWallets() ?? []
    }
        
    private func setupWallet(id: UUID) {
        syncWallets()
        
        if let wallet = _wallets?.first(where: { $0.walletID == id }) {
            guard let seed = secureStorage.data(for: wallet.key) else { return }
            setCurrent(wallet: wallet.setup(data: seed))
        } else {
            localStorage.removeCurrentWalletID()
            state = .createWallet
        }
    }
    
    private func setCurrent(wallet: DBWallet) {
        let listeners = wallet.assets.map{ $0.transactionAdaper }
        
        disposeBag = DisposeBag()
        notificationService.clear()
        
        for listener in listeners {
            listener?.transactionRecordsObservable
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] records in
                    for record in records {
                        let type: String
                        
                        switch record.type {
                        case .incoming, .sentToSelf:
                            type = "incoming"
                        case .outgoing:
                            type = "outgoing"
                        case .approve:
                            type = "approve"
                        case .transfer:
                            type = "transfer"
                        }
                        
                        let message = "New \(type) transaction \(record.amount) \(listener!.coin.code)"
                        let notification = PNotification(message: message)
                        self?.notificationService.notify(notification)
                    }
                }, onError: { error in
                    print("Cannot setup silteners")
                })
                .disposed(by: disposeBag)
        }
        
        currentWallet = wallet
        localStorage.setCurrentWalletID(wallet.walletID)
        state = .currentWallet
    }
    
    private func deleteWallets(wallets: [DBWallet]) {
        try? secureStorage.clear()
        try? dbStorage.deleteWallets(wallets: wallets)
    }
    
    func onTerminate() {
        currentWallet?.stop()
    }
    
    func didEnterBackground() {
        currentWallet?.stop()
    }
        
    func didBecomeActive() {
        currentWallet?.start()
    }
}

extension WalletsService: IWalletsService {    
    func createWallet(model: NewWalletModel) {
        guard let data = model.seedData else {
            fatalError("Cannot get seed data")
        }
        
        currentWallet?.stop()
        
        if let newWallet = try? dbStorage.createWallet(model: model) {
            secureStorage.save(data: data, key: newWallet.key)
            setCurrent(wallet: newWallet.setup(data: data))
        } else {
            state = .createWallet
        }
        
        syncWallets()
    }
    
    func restoreWallet(model: NewWalletModel) {
        createWallet(model: model)
    }
    
    func switchWallet(_ wallet: IWallet) {
        currentWallet?.stop()
        setupWallet(id: wallet.walletID)
    }
    
    func restoreWallet() {
        state = .restoreWallet
    }
    
    func deleteWallet(_ wallet: DBWallet) {
        if let nextWallet = wallets?.first(where: { $0.walletID != wallet.id }) {
            switchWallet(nextWallet)
            try? dbStorage.delete(wallet: wallet)
        } else {
            currentWallet?.stop()
            currentWallet = nil
            
            localStorage.removeCurrentWalletID()
            try? dbStorage.delete(wallet: wallet)
            
            state = .createWallet
        }
        
        syncWallets()
    }
    
    func clear() {
        syncWallets()
                
        if let walletsToClear = _wallets {
            deleteWallets(wallets: walletsToClear)
        }
    }
}
