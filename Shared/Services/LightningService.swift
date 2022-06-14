//
//  LightningService.swift
//  Portal
//
//  Created by farid on 6/12/22.
//

import Foundation
import Combine
import BitcoinCore
import LDKFramework_Mac

class LightningService: ILightningService {
    var dataService: ILightningDataService
    var manager: ILightningChannelManager
    
    var blockChainDataSynced = CurrentValueSubject<Bool, Never>(false)
    
    private var bitcoinAdapter: BitcoinAdapter
    private var subscriptions = Set<AnyCancellable>()
    
    init(adapter: BitcoinAdapter, dataService: ILightningDataService, notificationService: INotificationService) {
        self.bitcoinAdapter = adapter
        self.dataService = dataService
        
        manager = LightningChannelManager(adapter: bitcoinAdapter, dataService: dataService, notificationService: notificationService)
                        
        bitcoinAdapter.transactionRecords
            .sink { [weak self] txs in
                guard let self = self else { return }
                
                for tx in txs {
                    print("=================================")
                    print("BTC transaction")
                    print("id: \(tx.transactionHash)")
                    print("amount: \(tx.amount)")
                    print("fee: \(tx.fee ?? 0)")
                    print("confirmations: \(tx.confirmations(lastBlockHeight: self.bitcoinAdapter.lastBlockInfo?.height))")
                    print("=================================")
                }
            }
            .store(in: &subscriptions)
        
        bitcoinAdapter.balanceStateUpdated
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }

                let state = self.bitcoinAdapter.balanceState
                if case let .syncing(currentProgress, _) = state {
                    print("Syncing... \(currentProgress)%")
                    
                    if self.blockChainDataSynced.value != false {
                        self.blockChainDataSynced.send(false)
                    }
                }
                if case .synced  = state {
                    Task {
                        do {
                            try await self.syncBlockchainData()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            .store(in: &subscriptions)
        
        bitcoinAdapter.lastBlockUpdated
            .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .flatMap(maxPublishers: .max(1)) {
                Just($0).delay(for: .seconds(2), scheduler: DispatchQueue.global(qos: .background))
            }
            .sink { [weak self] newBlock in
                guard let self = self, self.blockChainDataSynced.value, let block = newBlock else { return }
                
                Task {
                    do {
                        try await self.connect(block: block)
                    } catch {
                        print(error)
                    }
                }
            }
            .store(in: &subscriptions)
    }
        
    func connect(node: LightningNode) -> Bool {
        node.connected = manager.peerNetworkHandler.connect(address: node.host, port: node.port, theirNodeId: node.nodeId)
        print("Node: \(node.alias) is \(node.connected ? "connected": "disconnected")")
        return node.connected
    }
    
    func disconnect(node: LightningNode) {
        guard node.connected else { return }
        manager.peerManager.disconnect_by_node_id(node_id: node.nodeId, no_connection_possible: false)
        node.connected = false
        print("Node: \(node.alias) is \(node.connected ? "connected": "disconnected")")
    }
    
    func openChannelWith(node: LightningNode, sat: Int64) {
        guard node.connected else {
            print("Cannot open a channel with \(node.alias): ISN'T CONNECTED")
            return
        }
        
        let userChannelId = UInt64.random(in: 10...1000)
        let config = UserConfig()
        
        let channelOpenResult = manager.channelManager.create_channel(
            their_network_key: node.nodeId,
            channel_value_satoshis: UInt64(sat),
            push_msat: 0,
            user_channel_id: userChannelId,
            override_config: config
        )
                
        if channelOpenResult.isOk() {
            print("Channel is open. Waiting funding tx")
            let channel = LightningChannel(id: Int16(userChannelId), satValue: sat, state: .waitingFunds, nodeAlias: node.alias)
            node.channels.append(channel)
            dataService.update(node: node)
        } else if let errorDetails = channelOpenResult.getError(){
            print("Channel open failed")
            
            if let error = errorDetails.getValueAsAPIMisuseError() {
                print("Misuse: \(error.getErr())")
            } else if let error = errorDetails.getValueAsRouteError() {
                print("Route: \(error.getErr())")
            } else if let error = errorDetails.getValueAsChannelUnavailable() {
                print("Channel Unavailable: \(error.getErr())")
            } else if let error = errorDetails.getValueAsFeeRateTooHigh() {
                print("fee rate: \(error.getErr())")
            } else if let error = errorDetails.getValueAsIncompatibleShutdownScript() {
                print("incompatible shutdown script: \(error.getScript())")
            }
        }
    }
    
    func createInvoice(amount: String, memo: String) -> String? {
        if let satoshiAmount = Int(amount) {
            let amount = Option_u64Z(value: UInt64(satoshiAmount * 1000))
            let descr = memo
            
            let result = Bindings.swift_create_invoice_from_channelmanager(
                channelmanager: manager.channelManager,
                keys_manager: manager.keysManager.as_KeysInterface(),
                network: LDKCurrency_BitcoinTestnet,
                amt_msat: amount,
                description: descr
            )

            if result.isOk(), let invoice = result.getValue() {
                let invoiceString = invoice.to_str()
                print("================================")
                print("INVOICE: \(invoiceString)")
                print("================================")
                
                let payment = LightningPayment(invoice: invoice, memo: memo)
                dataService.save(payment: payment)
                                                
                return invoiceString
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func pay(invoice: String) throws {
        guard let payer = manager.payer else { return }
        let result = Invoice.from_str(s: invoice)
            
        guard result.isOk() else { return }
        
        let invoiceValue = result.getValue()!
        let payerResult = payer.pay_invoice(invoice: invoiceValue)
        
        if payerResult.isOk() {
            print("Payment sent")
        } else {
            if let error = payerResult.getError() {
                switch error.getValueType() {
                case .Invoice:
                    print("invocie error")
                    print("\(error.getValueAsInvoice()!)")
                case .Routing:
                    print("routing error")
                    print("\(error.getValueAsRouting()!)")
                case .Sending:
                    print("sending error")
                    print("\(error.getValueAsSending()!)")
                case .none:
                    print("unknown error")
                }
            }
        }
    }
}

extension LightningService {
    enum FetchingDataError: Error {
        case invalidURL
        case badHTTPResponseStatus
        case badHTTPResponseType
        case dataTransformation
        case missingBinary
    }
    //TODO: - move api calls to network layer
    private func getBlockBinary(hash: String?) async throws -> Data {
        guard let _hash = hash else { throw FetchingDataError.invalidURL }
        let urlString = "https://blockstream.info/testnet/api/block/\(_hash)/raw"
        guard let url = URL(string: urlString) else {
            throw FetchingDataError.invalidURL
        }
        let request = URLRequest(url: url)
        let (blockData, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw FetchingDataError.badHTTPResponseStatus
        }
        guard let mime = httpResponse.mimeType, mime == "application/octet-stream" else {
            throw FetchingDataError.badHTTPResponseType
        }
        
        return blockData
    }
    
    private func connect(block: LastBlockInfo) async throws {
        let bestBlockHeight = manager.channelManager.current_best_block().height()
        
        guard block.height == bestBlockHeight + 1 else { return }
        
        let rawBlockData = try await getBlockBinary(hash: block.headerHash)
        
        let blockBinary = rawBlockData.bytes
        let blockHeight = UInt32(block.height)

        let channelManagerListener = manager.channelManager.as_Listen()
        channelManagerListener.block_connected(block: blockBinary, height: blockHeight)

        let chainMonitorListener = manager.chainMonitor.as_Listen()
        chainMonitorListener.block_connected(block: blockBinary, height: blockHeight)
                
        print("Block connected: \(block)")
    }
    
    func syncBlockchainData() async throws {
        let bestBlockHeight = manager.channelManager.current_best_block().height()
        let adapterBestBlockHeight = bitcoinAdapter.lastBlockInfo?.height ?? 0
        let newBlocks = bitcoinAdapter.blocks(from: Int(bestBlockHeight + 1), to: adapterBestBlockHeight)
                
        let channelManagerListener = manager.channelManager.as_Listen()
        let chainMonitorListener = manager.chainMonitor.as_Listen()
        
        for block in newBlocks {
            let blockBinary = try await getBlockBinary(hash: block.headerHash.reversedHex)
            let blockBytes = blockBinary.bytes
            let blockHeight = UInt32(block.height)
            channelManagerListener.block_connected(block: blockBytes, height: blockHeight)
            chainMonitorListener.block_connected(block: blockBytes, height: blockHeight)
        }
        
        manager.chainSyncCompleted()
        blockChainDataSynced.send(true)
                
        for node in dataService.nodes {
            for channel in node.channels {
                if channel.state != .closed && !node.connected {
                    guard connect(node: node) else {
                        print("Unable connect to \(node.alias)")
                        continue
                    }
                }
            }
        }
        
        print("=========================")
        print("Blockchain data synced:\nOn-chain balance: \(bitcoinAdapter.balance) BTC")
        print("=========================")
    }
}
