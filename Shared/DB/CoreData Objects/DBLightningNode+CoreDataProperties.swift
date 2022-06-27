//
//  DBLightningNode+CoreDataProperties.swift
//  Portal
//
//  Created by farid on 6/12/22.
//
//

import Foundation
import CoreData


extension DBLightningNode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBLightningNode> {
        return NSFetchRequest<DBLightningNode>(entityName: "DBLightningNode")
    }

    @NSManaged public var alias: String
    @NSManaged public var host: String
    @NSManaged public var port: Int16
    @NSManaged public var publicKey: String
    @NSManaged public var channels: NSOrderedSet

}

// MARK: Generated accessors for channels
extension DBLightningNode {

    @objc(addChannelsObject:)
    @NSManaged public func addToChannels(_ value: DBLightningChannel)

    @objc(removeChannelsObject:)
    @NSManaged public func removeFromChannels(_ value: DBLightningChannel)

    @objc(addChannels:)
    @NSManaged public func addToChannels(_ values: NSSet)

    @objc(removeChannels:)
    @NSManaged public func removeFromChannels(_ values: NSSet)

}

extension DBLightningNode : Identifiable {

}
