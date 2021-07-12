//
//  DBWallet+CoreDataProperties.swift
//  Portal (iOS)
//
//  Created by Farid on 30.05.2021.
//
//

import Foundation
import CoreData


extension DBWallet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBWallet> {
        return NSFetchRequest<DBWallet>(entityName: "DBWallet")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var fiatCurrency: String
    @NSManaged public var btcBipFormat: Int16
    @NSManaged public var txs: NSSet?
    @NSManaged public var wallets: DBStorage?

}

extension DBWallet : Identifiable {

}
