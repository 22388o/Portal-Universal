//
//  IAccountStorage.swift
//  Portal
//
//  Created by Farid on 22.07.2021.
//

import Foundation
import CoreData

protocol IAccountStorage {
    var context: NSManagedObjectContext { get }
    var allAccountRecords: [AccountRecord] { get }
    func save(accountRecord: AccountRecord)
    func deleteAccountRecord(by id: String)
    func deleteAllAccountRecords()
}
