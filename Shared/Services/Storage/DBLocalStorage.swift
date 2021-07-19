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
    
    func fetchWallets() throws -> [AccountRecord]? {
        let request = AccountRecord.fetchRequest() as NSFetchRequest<AccountRecord>
                
        do {
            let wallets = try context.fetch(request)
            return wallets
        } catch {
            throw DBStorageError.cannotFetchWallets(error: error)
        }
    }
    
    func createWallet(model: NewAccountModel) throws -> AccountRecord? {
        let newWallet = AccountRecord(model: model, context: context)
        
        context.insert(newWallet)
        
        do {
            try context.save()
            return newWallet
        } catch {
            throw DBStorageError.cannotSaveContext(error: error)
        }
    }
    
    func delete(wallet: AccountRecord) throws {
        context.delete(wallet)
        do {
            try context.save()
        } catch {
            throw DBStorageError.cannotSaveContext(error: error)
        }
    }
    
    func deleteWallets(wallets: [AccountRecord]) throws {
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

extension DBlocalStorage: IIDBStorage {
    func accountRecords() -> [AccountRecord] {
        let request = AccountRecord.fetchRequest() as NSFetchRequest<AccountRecord>
                
        if let records = try? context.fetch(request) {
            return records
        } else {
            return []
        }
    }
    
    func account(id: UUID) -> AccountRecord? {
        accountRecords().first(where: { $0.id == id} )
    }
    
    func save(account: Account) throws {
        
    }
    
    func createAccount(model: NewAccountModel) -> AccountRecord? {
        let record = AccountRecord(model: model, context: context)
        
        context.insert(record)
        try? context.save()
                
        return record
    }
    
    func deleteAccount(id: String) throws {
        
    }
    
    func delete(account: Account) throws {
        
    }
    
    func deleteAccounts(accounts: [Account]) throws {
        
    }
    
    func clear() {
        
    }
}
