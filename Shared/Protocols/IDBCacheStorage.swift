//
//  IDBCacheStorage.swift
//  Portal
//
//  Created by Farid on 21.10.2021.
//

import Coinpaprika
import CoreData

protocol IDBCacheStorage {
    var context: NSManagedObjectContext { get }
    var tickers: [Ticker] { get }
    var fiatCurrencies: [FiatCurrency] { get }
    
    func store(fiatCurrencies: [FiatCurrency])
    func store(tickers: [Ticker]?)
}
