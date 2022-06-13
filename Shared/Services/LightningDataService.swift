//
//  LightningDataService.swift
//  Portal
//
//  Created by farid on 6/12/22.
//

import Foundation

class LightningDataService: ILightningDataService {
    
    private let storage: ILightningDataStorage
    
    init(storage: ILightningDataStorage) {
        self.storage = storage
        
        if nodes.isEmpty {
            try? storage.save(nodes: LightningNode.sampleNodes)
        }
    }
    
    var channelManagerData: Data? {
        do {
            return try storage.fetchChannelManager()
        } catch {
            print("Error fetching channel manager data: \(error)")
            return nil
        }
    }
    
    var networkGraph: Data? {
        do {
            return try storage.fetchNetGraph()
        } catch {
            print("Error fetching net graph data: \(error)")
            return nil
        }
    }
    
    var channelMonitors: [Data]? {
        do {
            return try storage.fetchChannelMonitors()
        } catch {
            print("Error fetching channel monitor data: \(error)")
            return nil
        }
    }
        
    var nodes: [LightningNode] {
        do {
            return try storage.fetchNodes()
        } catch {
            print("Error nodes data: \(error)")
            return []
        }
    }
    
    var channels: [LightningChannel] {
        do {
            return try storage.fetchChannels()
        } catch {
            print("Error fetching channles data: \(error)")
            return []
        }
    }
    
    var payments: [LightningPayment] {
        do {
            return try storage.fetchPayments()
        } catch {
            print("Error fetching payments data: \(error)")
            return []
        }
    }
    
    func update(node: LightningNode) {
        do {
            try storage.update(node: node)
        } catch {
            print("Error updating node data: \(error)")
        }
    }
    
    func update(channel: LightningChannel) {
        do {
            try storage.update(channel: channel)
        } catch {
            print("Error updating channel data: \(error)")
        }
    }
    
    func update(payment: LightningPayment) {
        do {
            try storage.update(payment: payment)
        } catch {
            print("Error updating payment data: \(error)")
        }
    }
    
    func save(channel: LightningChannel) {
        do {
            try storage.save(channel: channel)
        } catch {
            print("Error saving channle data: \(error)")
        }
    }
    
    func save(payment: LightningPayment) {
        do {
            try storage.save(payment: payment)
        } catch {
            print("Error saving payment data: \(error)")
        }
    }
    
    func save(channelManager: Data) {
        do {
            try storage.save(channelManager: channelManager)
        } catch {
            print("Error saving channel manager data: \(error)")
        }
    }
    
    func save(networkGraph: Data) {
        do {
            try storage.save(networkGraph: networkGraph)
        } catch {
            print("Error saving network graph data: \(error)")
        }
    }
    
    func update(channelMonitor: Data, id: String) {
        do {
            try storage.update(channelMonitor: channelMonitor, id: id)
        } catch {
            print("Error updating channle monitor data: \(error)")
        }
    }
    
    func channelWith(id: UInt64) -> LightningChannel? {
        var channel: LightningChannel?
        do {
            channel = try storage.channelWith(id: id)
        } catch {
            print("Fetching channel with id: \(id) error: \(error)")
        }
        return channel
    }
    
    func removeChannelWith(id: UInt64) {
        do {
            try storage.removeChannelWith(id: id)
        } catch {
            print("Removing channel with id: \(id) error: \(error)")
        }
    }
}
