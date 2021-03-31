//
//  DBWallet+CoreDataProperties.swift
//  Portal
//
//  Created by Farid on 27.03.2021.
//
//

import Foundation
import CoreData


extension DBWallet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBWallet> {
        return NSFetchRequest<DBWallet>(entityName: "DBWallet")
    }

    @NSManaged public var fiatCurrencyCode: String
    @NSManaged public var id: UUID
    @NSManaged public var name: String

}

extension DBWallet : Identifiable {

}
