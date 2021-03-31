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
    @Published var currentWallet: IWallet?
    var wallets: [IWallet]?
    
    private let keychainStorage: KeychainStorage
    private var context: NSManagedObjectContext?

    static private let currentWalletIDKey = "CURRENT_WALLET_ID"
    
    private var currentWalletID: String? {
        get {
            return keychainStorage.string(for: WalletsService.currentWalletIDKey)
        }
        set {
            guard let value = newValue else { return }
            self.keychainStorage.save(string: value, for: WalletsService.currentWalletIDKey)
        }
    }
    
    convenience init(mockedWallet: IWallet) {
        self.init()
        currentWallet = mockedWallet
    }
    
    init(context: NSManagedObjectContext? = nil) {
        //context is optional for tests
        self.keychainStorage = KeychainStorage()
        
        guard context != nil else { return }
        
        self.context = context
        
        fetchWallets()
        setupCurrentWallet()
    }
    
    private func fetchWallets() {
        let request = DBWallet.fetchRequest() as NSFetchRequest<DBWallet>
                
        if let wallets = try? self.context?.fetch(request) {
//            clearWallets(wallets: wallets)
            self.wallets = wallets
        }
    }
    
    private func setupCurrentWallet() {
        if let fetchedCurrentWalletID = currentWalletID {
            setupWallet(id: fetchedCurrentWalletID)
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
    func setupWallet(id: String) {
        if let current = wallets?.first(where: { $0.walletID.uuidString == id }) {
            currentWallet = current
            
            guard
                let key = (currentWallet as? DBWallet)?.key,
                let data = keychainStorage.data(for: key) else { return }
            
            (currentWallet as? DBWallet)?.setup(data: data)
        } else {
            fatalError("Wallet with id \(id) isn't exist")
        }
    }
    
    func createWallet(model: NewWalletModel) {
        guard let context = self.context else {
            fatalError("Cannot get context to create wallet.")
        }
                    
        guard let data = model.seedData else {
            fatalError("Cannot get seed data")
        }
        
        let newWallet = DBWallet(model: model, context: context)
        newWallet.setup(data: data)
        saveSeed(data: data, key: newWallet.key)
        
        currentWalletID = newWallet.id.uuidString
        currentWallet = newWallet
    }
    
    func restoreWallet() {
        
    }
}
