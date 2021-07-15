//
//  WalletsService.swift
//  Portal
//
//  Created by Farid on 14.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

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

    init(dbStorage: IDBStorage, localStorage: ILocalStorage, secureStorage: IKeychainStorage) {
        print("\(#function) init")
        
        self.dbStorage = dbStorage
        self.localStorage = localStorage
        self.secureStorage = secureStorage
        
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
            currentWallet = wallet.setup(data: seed)
            localStorage.setCurrentWalletID(wallet.walletID)
            state = .currentWallet
        } else {
            localStorage.removeCurrentWalletID()
            state = .createWallet
        }
    }
        
    private func deleteWallets(wallets: [DBWallet]) {
        try? secureStorage.clear()
        try? dbStorage.deleteWallets(wallets: wallets)
    }
}

extension WalletsService: IWalletsService {    
    func createWallet(model: NewWalletModel) {
        guard let data = model.seedData else {
            fatalError("Cannot get seed data")
        }
        
        currentWallet?.stop()
        
        if let newWallet = try? dbStorage.createWallet(model: model) {
            currentWallet = newWallet.setup(data: data)
            secureStorage.save(data: data, key: newWallet.key)
            localStorage.setCurrentWalletID(newWallet.id)
            
            state = .currentWallet
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
