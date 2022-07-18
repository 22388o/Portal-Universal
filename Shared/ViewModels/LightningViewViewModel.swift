//
//  LightningViewViewModel.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import Foundation
#if os(macOS)
import LDKFramework_Mac
#else
import LDKFramework
#endif

class LightningViewViewModel: ObservableObject {
    @Published var payments: [LightningPayment] = []
    
    private let adapter: BitcoinAdapter
    private let channelManager: ChannelManager
    private let service: ILightningDataService
    
    var onChainBalanceString: String {
        "\(adapter.balance.rounded(toPlaces: 6))" + " BTC"
    }
    
    var channelsBalanceString: String {
        var balance: UInt64 = 0
        for channel in channelManager.list_usable_channels() {
            balance+=channel.get_balance_msat()/1000
        }
        return "\(balance) sat"
    }
    
    init(adapter: BitcoinAdapter, channelManager: ChannelManager, service: ILightningDataService) {
        self.adapter = adapter
        self.channelManager = channelManager
        self.service = service
    }
    
    func refreshPayments() {
//        payments = [
//            LightningPayment(id: UUID().uuidString, satAmount: 1000, created: Date(), description: "Coffee", state: .sent),
//            LightningPayment(id: UUID().uuidString, satAmount: 3000, created: Date(), description: "Dinner", state: .recieved),
//            LightningPayment(id: UUID().uuidString, satAmount: 5000, created: Date(), description: "Test2", state: .requested),
//            LightningPayment(id: UUID().uuidString, satAmount: 2030, created: Date(), description: "Test1", state: .recieved),
//            LightningPayment(id: UUID().uuidString, satAmount: 5000, created: Date(), description: "Test", state: .requested)
//        ]
        payments = service.payments.sorted(by: {$0.created > $1.created})
    }
}

extension LightningViewViewModel {
    static func config() -> LightningViewViewModel {
        guard let btcAdapter = Portal.shared.adapterManager.adapter(for: .bitcoin()) as? BitcoinAdapter else {
            fatalError("\(#function) Bitcoin Adapter :/")
        }
        guard let manager = Portal.shared.lightningService?.manager else {
            fatalError("\(#function) Channel manager :/")
        }
        guard let service = Portal.shared.lightningService?.dataService else {
            fatalError("\(#function) lightning data service :/")

        }
        return LightningViewViewModel(adapter: btcAdapter, channelManager: manager.channelManager, service: service)
    }
}
