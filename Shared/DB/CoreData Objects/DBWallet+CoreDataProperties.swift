//
//  DBWallet+CoreDataProperties.swift
//  Portal (iOS)
//
//  Created by Farid on 19.04.2021.
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
    @NSManaged public var txs: NSSet?
    @NSManaged public var wallets: DBStorage?

}

// MARK: Generated accessors for txs
extension DBWallet {

    @objc(addTxsObject:)
    @NSManaged public func addToTxs(_ value: DBTx)

    @objc(removeTxsObject:)
    @NSManaged public func removeFromTxs(_ value: DBTx)

    @objc(addTxs:)
    @NSManaged public func addToTxs(_ values: NSSet)

    @objc(removeTxs:)
    @NSManaged public func removeFromTxs(_ values: NSSet)

}

extension DBWallet : Identifiable {

}
