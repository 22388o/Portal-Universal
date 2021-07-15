//
//  DBLocalStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import CoreData

final class DBlocalStorage: IDBStorage {
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchWallets() throws -> [DBWallet]? {
        let request = DBWallet.fetchRequest() as NSFetchRequest<DBWallet>
                
        do {
            let wallets = try context.fetch(request)
            return wallets
        } catch {
            throw DBStorageError.cannotFetchWallets(error: error)
        }
    }
    
    func createWallet(model: NewWalletModel) throws -> DBWallet? {
        let newWallet = DBWallet(model: model, context: context)
        
        context.insert(newWallet)
        
        do {
            try context.save()
            return newWallet
        } catch {
            throw DBStorageError.cannotSaveContext(error: error)
        }
    }
    
    func delete(wallet: DBWallet) throws {
        context.delete(wallet)
        do {
            try context.save()
        } catch {
            throw DBStorageError.cannotSaveContext(error: error)
        }
    }
    
    func deleteWallets(wallets: [DBWallet]) throws {
        for wallet in wallets {
            context.delete(wallet)
        }
        
        do {
            try context.save()
        } catch {
            throw DBStorageError.cannotSaveContext(error: error)
        }
    }
}
