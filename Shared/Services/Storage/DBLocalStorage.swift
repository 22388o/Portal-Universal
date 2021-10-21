//
//  DBLocalStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import CoreData
import Combine

final class DBlocalStorage {
    var context: NSManagedObjectContext
    private var cache: DBCache?
    
    var tickers: [Ticker] = []
    var fiatCurrencies: [FiatCurrency] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadCache()
    }
    
    func delete(account: AccountRecord) throws {
        context.performAndWait {
            context.delete(account)
        }
        do {
            try context.save()
        } catch {
            throw DBStorageError.cannotSaveContext(error: error)
        }
    }
    
    private func loadCache() {
        context.performAndWait {
            let request = DBCache.fetchRequest() as NSFetchRequest<DBCache>
            
            do {
                self.cache = try context.fetch(request).first
                
                guard cache == nil else {
                    print("Cache fetched")
                    
                    tickers = fetchCachedTickers()
                    fiatCurrencies = fetchCachedFiatCurrencies()
                    
                    return
                }
                
                print("Creating cache db entity...")
                let cache = DBCache(context: context)
                context.insert(cache)
                try context.save()
                
                self.cache = cache
            } catch {
                print("Loading cache error: \(error)")
            }
        }
    }
    
    fileprivate func fetchCachedTickers() -> [Ticker] {
        guard let cache = self.cache, let tickersData = cache.tickersData else { return [] }
        let tickers = try? JSONDecoder().decode([Ticker].self, from: tickersData)
        print("Cached tickers fetched")
        return tickers ?? []
    }
    
    fileprivate func fetchCachedFiatCurrencies() -> [FiatCurrency] {
        guard let cache = self.cache, let fiatCUrrenciesData = cache.fiatCurrenciesData else { return [] }
        let currencies = try? JSONDecoder().decode([FiatCurrency].self, from: fiatCUrrenciesData)
        print("Cached fiat currencies fetched")
        return currencies ?? []
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
        context.performAndWait {
            context.insert(accountRecord)
            try? context.save()
        }
    }
    
    func deleteAccountRecord(by id: String) {
        
    }
    
    func deleteAllAccountRecords() {
        
    }
}

import Coinpaprika

extension DBlocalStorage: IDBCacheStorage {
    func store(tickers: [Ticker]?) {
        guard let tickers = tickers else { return }

        context.performAndWait {
            do {
                let tickersData = try JSONEncoder().encode(tickers)
                cache?.tickersData = tickersData
                try context.save()
                print("Tickers updated")
            } catch {
                print("Encoding error: \(error)")
            }
        }
        self.tickers = tickers
    }
    
    func store(fiatCurrencies: [FiatCurrency]) {
        context.performAndWait {
            do {
                let currenciesData = try JSONEncoder().encode(fiatCurrencies)
                cache?.fiatCurrenciesData = currenciesData
                try context.save()
                print("Fiat currencies updated")
            } catch {
                print("Encoding error: \(error)")
            }
        }
        self.fiatCurrencies = fiatCurrencies
    }
}
