//
//  DBLightningChannel+CoreDataProperties.swift
//  Portal
//
//  Created by farid on 6/12/22.
//
//

import Foundation
import CoreData


extension DBLightningChannel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBLightningChannel> {
        return NSFetchRequest<DBLightningChannel>(entityName: "DBLightningChannel")
    }

    @NSManaged public var channelID: Int16
    @NSManaged public var satValue: Int64
    @NSManaged public var state: Int16
    @NSManaged public var node: DBLightningNode

}

extension DBLightningChannel : Identifiable {

}
