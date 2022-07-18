//
//  OpenLightningChannelViewModel.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import Foundation
#if os(iOS)
import LDKFramework
#elseif os(macOS)
import LDKFramework_Mac
#endif

class OpenLightningChannelViewModel: ObservableObject {
    @Published var suggestedNodes: [LightningNode]
    @Published var openChannels: [LightningChannel]
    @Published var showAlert = false
    @Published var errorMessage = String()
        
    private let adapter: BitcoinAdapter
    private let service: ILightningService
    
    var channelBalance: UInt64 {
        var bal: UInt64 = 0
        for channel in service.manager.channelManager.list_usable_channels() {
            bal+=channel.get_balance_msat()/1000
        }
        return bal
    }
    
    init(adapter: BitcoinAdapter, service: ILightningService) {
        self.adapter = adapter
        self.service = service
        
        suggestedNodes = LightningNode.sampleNodes
        openChannels = [LightningChannel(id: Int16(12364), satValue: 20000, state: .open, nodeAlias: "OGLE-TR-122")]
    }
    
    func connect(node: LightningNode) -> Bool {
        service.connect(node: node)
    }
}

extension OpenLightningChannelViewModel {
    static func config() -> OpenLightningChannelViewModel {
        guard let adapter = Portal.shared.adapterManager.adapter(for: .bitcoin()) as? BitcoinAdapter else {
            fatalError("\(#function) bitcoin adapter :/")
        }
        guard let service = Portal.shared.lightningService else {
            fatalError("\(#function) channel manager :/")
        }
        return OpenLightningChannelViewModel(adapter: adapter, service: service)
    }
}
