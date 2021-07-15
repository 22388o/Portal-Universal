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
        
        setupCurrentWallet()
    }
    
    deinit {
        print("\(#function) deinit")
    }
    
    private func fetchWallets() {
        self._wallets = try? dbStorage.fetchWallets()
    }
    
    private func setupCurrentWallet() {
        if let fetchedCurrentWalletID = localStorage.getCurrentWalletID() {
            setupWallet(id: fetchedCurrentWalletID)
        } else {
            localStorage.removeCurrentWalletID()
            state = .createWallet
        }
    }
    
    private func setupWallet(id: UUID) {
        fetchWallets()
        
        if let wallet = _wallets?.first(where: { $0.walletID == id }) {
            guard let seed = secureStorage.data(for: wallet.key) else { return }
            setCurrent(wallet: wallet.setup(data: seed))
        } else {
            localStorage.removeCurrentWalletID()
            state = .createWallet
        }
    }
        
    private func deleteWallets(wallets: [DBWallet]) {
        try? secureStorage.clear()
        try? dbStorage.deleteWallets(wallets: wallets)
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
                        }
                        
                        let message = "New \(type) transaction \(record.amount) \(listener!.coin.code)"
                        let notification = PNotification(message: message)
                        self?.notificationService.add(notification)
                    }
                }, onError: { error in
                    print("Cannot setup silteners")
                })
                .disposed(by: disposeBag)
        }
        
        wallet.start()
        currentWallet = wallet
        localStorage.setCurrentWalletID(wallet.walletID)
        state = .currentWallet
    }
    
    func onTerminate() {
        currentWallet?.stop()
    }
    
    func willEnterForeground() {
//        currentWallet?.start()
    }
    
    func didBecomeActive() {
//        currentWallet?.start()
    }
}

extension WalletsService: IWalletsService {    
    func createWallet(model: NewWalletModel) {
        guard let data = model.seedData else {
            fatalError("Cannot get seed data")
        }
        
        currentWallet?.stop()
        
        if let newWallet = try? dbStorage.createWallet(model: model) {
            setCurrent(wallet: newWallet.setup(data: data))
            secureStorage.save(data: data, key: newWallet.key)
        } else {
            state = .createWallet
        }
        
        fetchWallets()
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
        
        fetchWallets()
    }
    
    func clear() {
        fetchWallets()
                
        if let walletsToClear = _wallets {
            deleteWallets(wallets: walletsToClear)
        }
    }
}
