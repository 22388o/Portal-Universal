//
//  OpenLightningChannelViewModel.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import Foundation

class OpenLightningChannelViewModel: ObservableObject {
    @Published var suggestedNodes: [LightningNode]
    @Published var openChannels: [LightningChannel]
    @Published var showAlert = false
    @Published var errorMessage = String()
        
//    var btcAdapter = PolarConnectionExperiment.shared.bitcoinAdapter
    var channelBalance: UInt64 {
//        var bal: UInt64 = 0
//        for channel in PolarConnectionExperiment.shared.service!.manager.channelManager.list_usable_channels() {
//            bal+=channel.get_balance_msat()/1000
//        }
        return 0//bal
    }
    
    init() {
//        exchangerViewModel = .init(coin: .bitcoin(), currency: .fiat(USD), ticker: nil)
        suggestedNodes = LightningNode.sampleNodes
        openChannels = [LightningChannel(id: Int16(12364), satValue: 20000, state: .open, nodeAlias: "OGLE-TR-122")]
    }
    
    func openAChannel(node: LightningNode) {
//        if let decimalAmount = Decimal(string: exchangerViewModel.assetValue) {
//            let satoshiAmount = btcAdapter.convertToSatoshi(value: decimalAmount)
//            selectedNode = node
////            PolarConnectionExperiment.shared.service?.openChannelWith(node: node, sat: satoshiAmount)
//            channelIsOpened.toggle()
//        }
    }
    
    func sendPayment() {
//        try? PolarConnectionExperiment.shared.service?.pay(invoice: "")
    }
}
