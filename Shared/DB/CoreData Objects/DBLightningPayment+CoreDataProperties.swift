//
//  DBLightningPayment+CoreDataProperties.swift
//  Portal
//
//  Created by farid on 6/12/22.
//
//

import Foundation
import CoreData


extension DBLightningPayment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBLightningPayment> {
        return NSFetchRequest<DBLightningPayment>(entityName: "DBLightningPayment")
    }

    @NSManaged public var created: Date
    @NSManaged public var expires: Date?
    @NSManaged public var invoice: String?
    @NSManaged public var memo: String
    @NSManaged public var paymentID: String
    @NSManaged public var satValue: Int64
    @NSManaged public var state: Int16

}

extension DBLightningPayment : Identifiable {

}
