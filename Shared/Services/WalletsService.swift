//
//  WalletsService.swift
//  Portal
//
//  Created by Farid on 14.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import CoreData

final class WalletsService: ObservableObject {
    enum State {
        case currentWallet, createWallet, restoreWallet
    }
    
    @Published var state: State = .createWallet
    @Published var currentWallet: IWallet?
    
    var wallets: [IWallet]? { _wallets }
    
    private var _wallets: [DBWallet]?
    private let keychainStorage: KeychainStorage
    private var context: NSManagedObjectContext?

    static private let currentWalletIDKey = "CURRENT_WALLET_ID"
    
    private var currentWalletID: UUID? {
        get {
            guard let uuidString = keychainStorage.string(for: WalletsService.currentWalletIDKey) else {
                return nil
            }
            return UUID(uuidString: uuidString)
        }
        set {
            guard let value = newValue else { return }
            keychainStorage.save(string: value.uuidString, for: WalletsService.currentWalletIDKey)
        }
    }
    
    convenience init(mockedWallet: IWallet) {
        self.init()
        state = .currentWallet
        currentWallet = mockedWallet
    }
    
    init(context: NSManagedObjectContext? = nil) {
        print("\(#function) init")
        self.keychainStorage = KeychainStorage()
        
        guard context != nil else { return }
        
        self.context = context
        
        setupCurrentWallet()
    }
    
    deinit {
        print("\(#function) deinit")
    }
    
    private func fetchWallets() {
        let request = DBWallet.fetchRequest() as NSFetchRequest<DBWallet>
                
        if let wallets = try? self.context?.fetch(request) {
            self._wallets = wallets
        }
    }
    
    private func setupCurrentWallet() {
        if let fetchedCurrentWalletID = currentWalletID {
            setupWallet(id: fetchedCurrentWalletID)
        } else {
            try? keychainStorage.remove(key: WalletsService.currentWalletIDKey)
            state = .createWallet
        }
    }
    
    private func setupWallet(id: UUID) {
        fetchWallets()
        
        if let wallet = _wallets?.first(where: { $0.walletID == id }) {
            guard let data = keychainStorage.data(for: wallet.key), let seed = data.toStringArray else { return }
            currentWallet = wallet.setup(seed: seed)
            currentWalletID = wallet.walletID
            state = .currentWallet
        } else {
            fatalError("Wallet with id \(id) isn't exist")
        }
    }
    
    private func saveSeed(data: Data, key: String) {
        if Device.hasSecureEnclave {
            //TODO: - Implement secure enclave implementation
            keychainStorage.save(data: data, key: key)
        } else {
            keychainStorage.save(data: data, key: key)
        }
    }
    
    private func clearWallets(wallets: [DBWallet]) {
        try? keychainStorage.clear()
        
        for wallet in wallets {
            context?.delete(wallet)
        }
        
        try? context?.save()
    }
}

extension WalletsService: IWalletsService {    
    func createWallet(model: NewWalletModel) {
        guard let context = self.context else {
            fatalError("Cannot get context to create wallet.")
        }
                    
        guard let data = model.seedData else {
            fatalError("Cannot get seed data")
        }
        
        currentWallet?.stop()
        
        let newWallet = DBWallet(model: model, context: context)
        currentWallet = newWallet.setup(seed: model.seed)
        saveSeed(data: data, key: newWallet.key)
        currentWalletID = newWallet.id
        state = .currentWallet
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
            
            try? keychainStorage.remove(key: wallet.key)
            context?.delete(wallet)
            try? context?.save()
        } else {
            currentWallet?.stop()
            currentWallet = nil
            
            try? keychainStorage.remove(key: WalletsService.currentWalletIDKey)
            state = .createWallet

            try? keychainStorage.remove(key: wallet.key)
            context?.delete(wallet)
            try? context?.save()
        }
        fetchWallets()
    }
    
    func clear() {
        fetchWallets()
                
        if let walletsToClear = _wallets {
            clearWallets(wallets: walletsToClear)
        }
    }
}
