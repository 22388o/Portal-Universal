//
//  AccountRecord+CoreDataProperties.swift
//  
//
//  Created by Farid on 19.07.2021.
//
//

import Foundation
import CoreData


extension AccountRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountRecord> {
        return NSFetchRequest<AccountRecord>(entityName: "AccountRecord")
    }

    @NSManaged public var btcBipFormat: Int16
    @NSManaged public var fiatCurrency: String
    @NSManaged public var id: String
    @NSManaged public var name: String
}
