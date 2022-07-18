//
//  LightningChannelManager.swift
//  Portal
//
//  Created by farid on 6/13/22.
//

import Foundation
import BitcoinCore
#if os(macOS)
import LDKFramework_Mac
#else
import LDKFramework
#endif

class LightningChannelManager: ILightningChannelManager {
    private var constructor: ChannelManagerConstructor
    
    var channelManager: ChannelManager {
        constructor.channelManager
    }
    
    var payer: InvoicePayer? {
        constructor.payer
    }
    
    var peerManager: PeerManager {
        constructor.peerManager
    }
    
    var peerNetworkHandler: TCPPeerHandler {
        constructor.getTCPPeerHandler()
    }
    
    var chainMonitor: ChainMonitor
    var keysManager: KeysManager
    var channelManagerPersister: ExtendedChannelManagerPersister
    var dataService: ILightningDataService
    
    init(lastBlock: LastBlockInfo?, dataService: ILightningDataService, notificationService: INotificationService) {
        self.dataService = dataService
        
        let userConfig = UserConfig()
        let network = LDKNetwork_Testnet
        
        let filter = LDKFilter()
        let filterOption = Option_FilterZ(value: filter)
        let feeEstimator = LDKFeesEstimator()
        let persister = LDKChannelPersister(dataService: dataService)
        let broadcaster = LDKTestNetBroadcasterInterface()
        let logger = LDKLogger()
    
        let seed: [UInt8] = [UInt8](Data(base64Encoded: "13/12//////////////////////////////////11113")!)
        let timestampSeconds = UInt64(Date().timeIntervalSince1970)
        let timestampNanos = UInt32(truncating: NSNumber(value: timestampSeconds * 1000 * 1000))
        
        keysManager = KeysManager(seed: seed, starting_time_secs: timestampSeconds, starting_time_nanos: timestampNanos)
        
        chainMonitor = ChainMonitor(
            chain_source: filterOption,
            broadcaster: broadcaster,
            logger: logger,
            feeest: feeEstimator,
            persister: persister
        )
        
        if let channelManagerSerialized = dataService.channelManagerData?.bytes {
            //restoring node
            
            let networkGraphSerizlized = dataService.networkGraph?.bytes ?? []
            let channelMonitorsSeriaziled = dataService.channelMonitors?.map{ $0.bytes } ?? []

            do {
                constructor = try ChannelManagerConstructor(
                    channel_manager_serialized: channelManagerSerialized,
                    channel_monitors_serialized: channelMonitorsSeriaziled,
                    keys_interface: keysManager.as_KeysInterface(),
                    fee_estimator: feeEstimator,
                    chain_monitor: chainMonitor,
                    filter: filter,
                    net_graph_serialized: networkGraphSerizlized,
                    tx_broadcaster: broadcaster,
                    logger: logger
                )
            } catch {
                print("fatalError: \(error)")
                
                dataService.clearLightningData()
                
                //start new node
                
                let bestBlock = lastBlock ?? LastBlockInfo(height: 2278337, timestamp: 1655445673, headerHash: "000000000000006834c0a2e3507fe17d5ae5fb67e5fd32a1c03583eae7ecf08b")
                
                print("Best block: \(bestBlock)")
                
                guard
                    let reversedLastBlockHash = bestBlock.headerHash?.reversed,
                    let chainTipHash = reversedLastBlockHash.hexStringToBytes()
                else {
                    fatalError("header hash :/")
                }
            
                let chainTipHeight = UInt32(bestBlock.height)
                
                //test net genesis block hash
                let reversedGenesisBlockHash = "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943".reversed
                
                guard let genesisHash = reversedGenesisBlockHash.hexStringToBytes() else {
                    fatalError("genesisHash :/")
                }
                
                let networkGraph = NetworkGraph(genesis_hash: genesisHash)
                
                constructor = ChannelManagerConstructor(
                    network: network,
                    config: userConfig,
                    current_blockchain_tip_hash: chainTipHash,
                    current_blockchain_tip_height: chainTipHeight,
                    keys_interface: keysManager.as_KeysInterface(),
                    fee_estimator: feeEstimator,
                    chain_monitor: chainMonitor,
                    net_graph: networkGraph,
                    tx_broadcaster: broadcaster,
                    logger: logger
                )
            }

        } else {
            //start new node
            
            let bestBlock = lastBlock ?? LastBlockInfo(height: 2278337, timestamp: 1655445673, headerHash: "000000000000006834c0a2e3507fe17d5ae5fb67e5fd32a1c03583eae7ecf08b")
            
            guard
                let reversedLastBlockHash = bestBlock.headerHash?.reversed,
                let chainTipHash = reversedLastBlockHash.hexStringToBytes()
            else {
                fatalError("header hash :/")
            }
        
            let chainTipHeight = UInt32(bestBlock.height)
            
            //test net genesis block hash
            let reversedGenesisBlockHash = "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943".reversed
            
            guard let genesisHash = reversedGenesisBlockHash.hexStringToBytes() else {
                fatalError("genesisHash :/")
            }
            
            let networkGraph = NetworkGraph(genesis_hash: genesisHash)
            
            constructor = ChannelManagerConstructor(
                network: network,
                config: userConfig,
                current_blockchain_tip_hash: chainTipHash,
                current_blockchain_tip_height: chainTipHeight,
                keys_interface: keysManager.as_KeysInterface(),
                fee_estimator: feeEstimator,
                chain_monitor: chainMonitor,
                net_graph: networkGraph,
                tx_broadcaster: broadcaster,
                logger: logger
            )
        }
        
        let bestBlockHeight = constructor.channelManager.current_best_block().height()
        let bestBlockHash = constructor.channelManager.current_best_block().block_hash()
        print("Best block height: \(bestBlockHeight), hash: \(bestBlockHash.bytesToHexString())")
        
        channelManagerPersister = LDKChannelManagerPersister(
            channelManager: constructor.channelManager,
            dataService: dataService
        )
    }
    
    func chainSyncCompleted() {
        let scoringParams = ProbabilisticScoringParameters()
        if let networkGraph = constructor.net_graph {
            let probabalisticScorer = ProbabilisticScorer(params: scoringParams, network_graph: networkGraph)
            let score = probabalisticScorer.as_Score()
            let multiThreadedScorer = MultiThreadedLockableScore(score: score)
            constructor.chain_sync_completed(persister: channelManagerPersister, scorer: multiThreadedScorer)
        }
    }
}
