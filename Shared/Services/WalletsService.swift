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
        
        fetchWallets()
        setupCurrentWallet()
    }
    
    deinit {
        print("\(#function) deinit")
    }
    
    private func fetchWallets() {
        let request = DBWallet.fetchRequest() as NSFetchRequest<DBWallet>
                
        if let wallets = try? self.context?.fetch(request) {
//            clearWallets(wallets: wallets)
            self._wallets = wallets
        }
    }
    
    private func setupCurrentWallet() {
        if let fetchedCurrentWalletID = currentWalletID {
            setupWallet(id: fetchedCurrentWalletID)
        } else {
            state = .createWallet
        }
    }
    
    private func setupWallet(id: UUID) {
        if let wallet = _wallets?.first(where: { $0.walletID == id }) {
            guard let data = keychainStorage.data(for: wallet.key), let seed = data.toStringArray else { return }
            currentWallet = wallet.setup(seed: seed, isNewWallet: false)
            state = .currentWallet
        } else {
            fatalError("Wallet with id \(id) isn't exist")
        }
    }
    
    private func saveSeed(data: Data, key: String) {
        if Device.hasSecureEnclave {
            keychainStorage.save(data: data, key: key)
//            fatalError("Not implemented yet")
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
        
        if let currentWallet = currentWallet {
            for asset in currentWallet.assets {
                asset.kit?.stop()
            }
        }
        
        let newWallet = DBWallet(model: model, context: context)
        currentWallet = newWallet.setup(seed: model.seed, isNewWallet: true)
        saveSeed(data: data, key: newWallet.key)
        currentWalletID = newWallet.id
        state = .currentWallet
    }
    
    func restoreWallet(model: NewWalletModel) {
        guard let context = self.context else {
            fatalError("Cannot get context to create wallet.")
        }
                    
        guard let data = model.seedData else {
            fatalError("Cannot get seed data")
        }
        
        if let currentWallet = currentWallet {
            for asset in currentWallet.assets {
                asset.kit?.stop()
            }
        }
        
        let newWallet = DBWallet(model: model, context: context)
        currentWallet = newWallet.setup(seed: model.seed, isNewWallet: false)
        saveSeed(data: data, key: newWallet.key)
        
        currentWalletID = newWallet.id
        state = .currentWallet
    }
    
    func switchWallet(_ wallet: IWallet) {
        if let currentWallet = currentWallet {
            for asset in currentWallet.assets {
                asset.kit?.stop()
            }
        }
        currentWalletID = wallet.walletID
        setupWallet(id: wallet.walletID)
    }
    
    func restoreWallet() {
        state = .restoreWallet
    }
}
