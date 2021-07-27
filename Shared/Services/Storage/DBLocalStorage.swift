//
//  DBLocalStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import CoreData

final class DBlocalStorage {
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func delete(account: AccountRecord) throws {
        context.delete(account)
        do {
            try context.save()
        } catch {
            throw DBStorageError.cannotSaveContext(error: error)
        }
    }
}

extension DBlocalStorage: IDBStorage {
    func accountRecords() -> [AccountRecord] {
        let request = AccountRecord.fetchRequest() as NSFetchRequest<AccountRecord>
                
        if let records = try? context.fetch(request) {
            return records
        } else {
            return []
        }
    }
        
    func delete(account: Account) throws {
        if let record = accountRecords().first(where: { $0.id == account.id }) {
            try delete(account: record)
        }
    }
    
    func clear() {
        
    }
}

extension DBlocalStorage: IAccountStorage {
    var allAccountRecords: [AccountRecord] {
        let request = AccountRecord.fetchRequest() as NSFetchRequest<AccountRecord>
        if let records = try? context.fetch(request) {
            return records
        } else {
            return []
        }
    }
    
    func save(accountRecord: AccountRecord) {
        context.insert(accountRecord)
        try? context.save()
    }
    
    func deleteAccountRecord(by id: String) {
        
    }
    
    func deleteAllAccountRecords() {
        
    }
}
