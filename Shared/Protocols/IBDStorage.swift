//
//  IBDStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import CoreData

protocol IDBStorage {
    var context: NSManagedObjectContext { get }
    func accountRecords() -> [AccountRecord]
    func delete(account: Account) throws
    func clear()
}
