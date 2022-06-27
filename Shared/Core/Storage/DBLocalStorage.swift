//
//  DBLocalStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import CoreData
import Combine

final class DBlocalStorage {
    var context: NSManagedObjectContext
    private var cache: DBCache?
    
    var tickers: [Ticker] = []
    var fiatCurrencies: [FiatCurrency] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadCache()
    }
        
    private func loadCache() {
        context.performAndWait {
            let request = DBCache.fetchRequest() as NSFetchRequest<DBCache>
            
            do {
                self.cache = try context.fetch(request).first
                
                guard cache == nil else {
                    print("Cache fetched")
                    
                    tickers = fetchCachedTickers()
                    fiatCurrencies = fetchCachedFiatCurrencies()
                    
                    return
                }
                
                print("Creating cache db entity...")
                let cache = DBCache(context: context)
                context.insert(cache)
                try context.save()
                
                self.cache = cache
            } catch {
                print("Loading cache error: \(error)")
            }
        }
    }
            
    private func fetchCachedTickers() -> [Ticker] {
        guard let cache = self.cache, let tickersData = cache.tickersData else { return [] }
        let tickers = try? JSONDecoder().decode([Ticker].self, from: tickersData)
        print("Cached tickers fetched")
        return tickers ?? []
    }
    
    private func fetchCachedFiatCurrencies() -> [FiatCurrency] {
        guard let cache = self.cache, let fiatCUrrenciesData = cache.fiatCurrenciesData else { return [] }
        let currencies = try? JSONDecoder().decode([FiatCurrency].self, from: fiatCUrrenciesData)
        print("Cached fiat currencies fetched")
        return currencies ?? []
    }
}

extension DBlocalStorage: IAccountStorage {
    var accountRecords: [AccountRecord] {
        var accountRecords: [AccountRecord] = []

        context.performAndWait {
            let request = AccountRecord.fetchRequest() as NSFetchRequest<AccountRecord>

            if let records = try? context.fetch(request) {
                accountRecords = records
            }
        }

        return accountRecords
    }
    
    func save(accountRecord: AccountRecord) {
        context.performAndWait {
            context.insert(accountRecord)
            try? context.save()
        }
    }
    
    func update(account: Account) {
        context.performAndWait {
            if let record = accountRecords.first(where: { $0.id == account.id }) {
                switch account.btcNetworkType {
                case .mainNet:
                    record.btcNetwork = 0
                case .regTest:
                    record.btcNetwork = 2
                default:
                    record.btcNetwork = 1
                }
                
                switch account.ethNetworkType {
                case .ethMainNet:
                    record.ethNetwork = 0
                case .kovan:
                    record.ethNetwork = 2
                default:
                    record.ethNetwork = 1
                }
                
                record.coins = account.coins
                            
                record.confirmationThreshold = Int16(account.confirmationsThreshold)
                record.fiatCurrency = account.fiatCurrencyCode
                
                try? context.save()
            }
            
        }
    }
        
    func deleteAccount(_ account: Account) throws {
        if let record = accountRecords.first(where: { $0.id == account.id }) {
            context.performAndWait {
                context.delete(record)
            }
            do {
                try context.save()
            } catch {
                throw DBStorageError.cannotSaveContext(error: error)
            }
        }
    }
    
    func deleteAllAccountRecords() {
        
    }
    
    func clear() {

    }
}

import Coinpaprika

extension DBlocalStorage: IDBCacheStorage {
    func store(tickers: [Ticker]?) {
        guard let tickers = tickers else { return }

        context.performAndWait {
            do {
                let tickersData = try JSONEncoder().encode(tickers)
                cache?.tickersData = tickersData
                try context.save()
                print("Tickers updated")
            } catch {
                print("Encoding error: \(error)")
            }
        }
        
        self.tickers = tickers
    }
    
    func store(fiatCurrencies: [FiatCurrency]) {
        context.performAndWait {
            do {
                let currenciesData = try JSONEncoder().encode(fiatCurrencies)
                cache?.fiatCurrenciesData = currenciesData
                try context.save()
                print("Fiat currencies updated")
            } catch {
                print("Encoding error: \(error)")
            }
        }
        
        self.fiatCurrencies = fiatCurrencies
    }
}

extension DBlocalStorage: IPriceAlertStorage {    
    func alerts(accountId: String, coin: String) -> [PriceAlert] {
        var alerts: [PriceAlert] = []
        
        context.performAndWait {
            let request = PriceAlert.fetchRequest() as NSFetchRequest<PriceAlert>
            
            let accountIdPredicate = NSPredicate(format: "accountId = %@", accountId)
            let coinPredicate = NSPredicate(format: "coin = %@", coin)

            request.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    accountIdPredicate,
                    coinPredicate
                ]
            )

            if let records = try? context.fetch(request) {
                alerts = records
            }
        }
        
        return alerts
    }
    
    func addAlert(_ model: PriceAlertModel) {
        context.performAndWait {
            do {
                let alert = PriceAlert.init(context: context)
                
                alert.accountId = model.accountId
                alert.id = model.id
                alert.coin = model.coin
                alert.timestamp = model.timestamp
                alert.value = model.value
                alert.title = model.title
                
                context.insert(alert)
                
                try context.save()
            } catch {
                print("Encoding error: \(error)")
            }
        }
    }
    
    func deleteAlert(_ alert: PriceAlert) {
        context.performAndWait {
            do {
                context.delete(alert)
                try context.save()
            } catch {
                print("Encoding error: \(error)")
            }
        }
    }
}

enum DBError: Error {
    case missingContext
    case fetchingError
    case storingError
}

extension DBlocalStorage: ILightningDataStorage {
    func channelWith(id: UInt64) throws -> LightningChannel? {
        let request = DBLightningChannel.fetchRequest() as NSFetchRequest<DBLightningChannel>
        var channel: LightningChannel?
        
        try context.performAndWait {
            do {
                if let record = try context.fetch(request).first(where: { $0.channelID == id }) {
                    channel = LightningChannel(record: record)
                } else {
                    throw DBError.fetchingError
                }
            } catch {
                throw DBError.fetchingError
            }
        }
        
        return channel
    }
    
    func removeChannelWith(id: UInt64) throws {
        let request = DBLightningChannel.fetchRequest() as NSFetchRequest<DBLightningChannel>
        
        try context.performAndWait {
            do {
                if let record = try context.fetch(request).first(where: { $0.channelID == id }) {
                    context.delete(record)
                    try context.save()
                } else {
                    throw DBError.fetchingError
                }
            } catch {
                throw DBError.fetchingError
            }
        }
    }
    
    func update(channelMonitor: Data, id: String) throws {
        let request = DBChannelMonitor.fetchRequest() as NSFetchRequest<DBChannelMonitor>
        
        try context.performAndWait {
            do {
                if let record = try context.fetch(request).first(where: { $0.channelId == id }) {
                    record.data = channelMonitor
                } else {
                    let dbMonitor = DBChannelMonitor(context: context)
                    dbMonitor.channelId = id
                    dbMonitor.data = channelMonitor
                }
                
                try context.save()
            } catch {
                throw DBError.fetchingError
            }
        }
    }
    
    
    func fetchNetGraph() throws -> Data? {
        let request = DBLightningNetGraph.fetchRequest() as NSFetchRequest<DBLightningNetGraph>
        var netGraphData: Data?
        
        try context.performAndWait {
            do {
                let record = try context.fetch(request).first
                netGraphData = record?.data
            } catch {
                throw DBError.fetchingError
            }
        }
        
        return netGraphData
    }
    
    func fetchChannelManager() throws -> Data? {
        let request = DBLightningChannelManager.fetchRequest() as NSFetchRequest<DBLightningChannelManager>
        var channelManagerData: Data?
        
        try context.performAndWait {
            do {
                let record = try context.fetch(request).first
                channelManagerData = record?.data
            } catch {
                throw DBError.fetchingError
            }
        }
        
        return channelManagerData
    }
    
    func fetchChannelMonitors() throws -> [Data]? {
        let request = DBChannelMonitor.fetchRequest() as NSFetchRequest<DBChannelMonitor>
        var channelMonitors = [Data]()
        
        try context.performAndWait {
            do {
                let records = try context.fetch(request)
                for record in records {
                    channelMonitors.append(record.data!)
                }
            } catch {
                throw DBError.fetchingError
            }
        }
        
        return !channelMonitors.isEmpty ? channelMonitors : nil
    }
    

    func fetchNodes() throws -> [LightningNode] {
        let request = DBLightningNode.fetchRequest() as NSFetchRequest<DBLightningNode>
        var nodes = [LightningNode]()
        
        try context.performAndWait {
            do {
                let records = try context.fetch(request)
                nodes = records.map { LightningNode(record: $0) }
            } catch {
                throw DBError.fetchingError
            }
        }
        
        return nodes
    }
    
    func fetchChannels() throws -> [LightningChannel] {
        let request = DBLightningChannel.fetchRequest() as NSFetchRequest<DBLightningChannel>
        var channels = [LightningChannel]()
        
        try context.performAndWait {
            do {
                let records = try context.fetch(request)
                channels = records.map { LightningChannel(record: $0) }
            } catch {
                throw DBError.fetchingError
            }
        }
        
        return channels
    }
    
    func fetchPayments() throws -> [LightningPayment] {
        let request = DBLightningPayment.fetchRequest() as NSFetchRequest<DBLightningPayment>
        var payments = [LightningPayment]()
        
        try context.performAndWait {
            do {
                let records = try context.fetch(request)
                payments = records.map { LightningPayment(record: $0) }
            } catch {
                throw DBError.fetchingError
            }
        }
        
        return payments
    }
    
    func save(channelManager: Data) throws {
        let request = DBLightningChannelManager.fetchRequest() as NSFetchRequest<DBLightningChannelManager>
        
        try context.performAndWait {
            do {
                let records = try context.fetch(request)
                
                if let record = records.first {
                    record.data = channelManager
                } else {
                    let manager = DBLightningChannelManager(context: context)
                    manager.data = channelManager
                }
                try context.save()
            } catch {
                throw DBError.fetchingError
            }
        }
    }
    
    func save(networkGraph: Data) throws {
        let request = DBLightningNetGraph.fetchRequest() as NSFetchRequest<DBLightningNetGraph>
        
        try context.performAndWait {
            do {
                let records = try context.fetch(request)
                
                if let record = records.first {
                    record.data = networkGraph
                } else {
                    let network = DBLightningNetGraph(context: context)
                    network.data = networkGraph
                }
                
                try context.save()
            } catch {
                throw DBError.fetchingError
            }
        }
    }
    
    func save(nodes: [LightningNode]) throws {
        try context.performAndWait {
            do {
                for node in nodes {
                    let dbNode = DBLightningNode(context: context)
                    dbNode.alias = node.alias
                    dbNode.publicKey = node.publicKey
                    dbNode.host = node.host
                    dbNode.port = Int16(node.port)
                }
                try context.save()
            } catch {
                throw DBError.storingError
            }
        }
    }
    
    func save(channel: LightningChannel) throws {
        let newChannel = DBLightningChannel(context: context)
        newChannel.channelID = Int16(channel.id)
        newChannel.satValue = Int64(channel.satValue)
        newChannel.state = channel.state.rawValue
        
        try context.performAndWait {
            do {
                try context.save()
            } catch {
                throw DBError.fetchingError
            }
        }
    }
    
    func save(payment: LightningPayment) throws {
        let record = DBLightningPayment(context: context)
        record.paymentID = payment.id
        record.satValue = Int64(payment.satAmount)
        record.memo = payment.description
        record.created = payment.created
        record.expires = payment.expires
        record.state = payment.state.rawValue
        record.invoice = payment.invoice
        
        try context.performAndWait {
            do {
                try context.save()
            } catch {
                throw DBError.storingError
            }
        }

    }
    
    func update(node: LightningNode) throws {
        let request = DBLightningNode.fetchRequest() as NSFetchRequest<DBLightningNode>
        
        try context.performAndWait {
            do {
                let records = try context.fetch(request)
                
                if let record = records.first(where: { $0.publicKey == node.publicKey }) {
                    record.alias = node.alias
                    record.publicKey = node.publicKey
                    record.host = node.host
                    record.port = Int16(node.port)
                    
                    for channel in node.channels {
                        let channelRecord = DBLightningChannel(context: context)
                        channelRecord.satValue = Int64(channel.satValue)
                        channelRecord.channelID = Int16(channel.id)
                        channelRecord.state = channel.state.rawValue
                        
                        record.addToChannels(channelRecord)
                    }
                    
                    try context.save()
                } else {
                    throw DBError.storingError
                }
            } catch {
                throw DBError.fetchingError
            }
        }
    }
    
    func update(channel: LightningChannel) throws {
        let request = DBLightningChannel.fetchRequest() as NSFetchRequest<DBLightningChannel>
        
        try context.performAndWait {
            do {
                if let record = try context.fetch(request).first(where: { $0.channelID == channel.id }) {
                    record.state = channel.state.rawValue
                    record.satValue = Int64(channel.satValue)
                    try context.save()
                } else {
                    throw DBError.fetchingError
                }
            } catch {
                throw DBError.fetchingError
            }
        }
    }
    
    func update(payment: LightningPayment) throws {
        let request = DBLightningPayment.fetchRequest() as NSFetchRequest<DBLightningPayment>
        
        try context.performAndWait {
            do {
                let records = try context.fetch(request)
                
                if let record = records.first(where: { $0.paymentID == payment.id }) {
                    record.state = payment.state.rawValue
                    record.satValue = Int64(payment.satAmount)
                    record.memo = payment.description
                    record.created = payment.created
                    record.expires = payment.expires
                    record.invoice = payment.invoice
                    
                    try context.save()
                } else {
                    throw DBError.storingError
                }
            } catch {
                throw DBError.fetchingError
            }
        }
    }
    
    func clearLightningData() throws {
        do {
            try clearChannelManager()
            try clearNetGraph()
            try clearChannelMonitors()
            try clearChannels()
        } catch {
            print("Error clearing lightning data")
        }
    }
    
    private func clearChannelManager() throws {
        let channelManagerRequest = DBLightningChannelManager.fetchRequest() as NSFetchRequest<DBLightningChannelManager>
        
        try context.performAndWait {
            do {
                let records = try context.fetch(channelManagerRequest)
                
                for record in records {
                    context.delete(record)
                }
                
                try context.save()
            }
        }
    }
    
    private func clearNetGraph() throws {
        let networkGraphRequest = DBLightningNetGraph.fetchRequest() as NSFetchRequest<DBLightningNetGraph>
        
        try context.performAndWait {
            do {
                let records = try context.fetch(networkGraphRequest)
                
                for record in records {
                    context.delete(record)
                }
                
                try context.save()
            }
        }
    }
    
    private func clearChannelMonitors() throws {
        let channelMonitorsRequest = DBChannelMonitor.fetchRequest() as NSFetchRequest<DBChannelMonitor>
        
        try context.performAndWait {
            do {
                let records = try context.fetch(channelMonitorsRequest)
                
                for record in records {
                    context.delete(record)
                }
                
                try context.save()
            }
        }
    }
    
    private func clearChannels() throws {
        let channelsRequest = DBLightningChannel.fetchRequest() as NSFetchRequest<DBLightningChannel>
        
        try context.performAndWait {
            do {
                let records = try context.fetch(channelsRequest)
                
                for record in records {
                    context.delete(record)
                }
                
                try context.save()
            }
        }
    }
}
