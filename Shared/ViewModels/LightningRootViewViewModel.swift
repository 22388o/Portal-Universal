//
//  LightningRootViewViewModel.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import Foundation

class LightningRootViewViewModel: ObservableObject {
    @Published var createInvoice: Bool = false
    @Published var payInvoice: Bool = false
    @Published var manageChannels: Bool = false
//    @Published var showActivityDetails: Bool = false
    @Published var payments: [LightningPayment] = []
    
    var btcAdapter: IAdapter
//    var channelManager = PolarConnectionExperiment.shared.service!.manager.channelManager
//    var selectedPayment: LightningPayment?
    
    var onChainBalanceString: String {
        "0.000202" + " BTC"
    }
    
    var channelsBalanceString: String {
//        var balaance: UInt64 = 0
//        for channel in channelManager.list_usable_channels() {
//            balaance+=channel.get_balance_msat()/1000
//        }
        return "\(20000) sat"
    }
    
    init(adapter: IAdapter) {
        self.btcAdapter = adapter
    }
    
    func refreshPayments() {
        payments = [
            LightningPayment(id: UUID().uuidString, satAmount: 1000, created: Date(), description: "Coffee", state: .sent),
            LightningPayment(id: UUID().uuidString, satAmount: 3000, created: Date(), description: "Dinner", state: .recieved),
            LightningPayment(id: UUID().uuidString, satAmount: 5000, created: Date(), description: "Test2", state: .requested),
            LightningPayment(id: UUID().uuidString, satAmount: 2030, created: Date(), description: "Test1", state: .recieved),
            LightningPayment(id: UUID().uuidString, satAmount: 5000, created: Date(), description: "Test", state: .requested)
        ]
    }
}

extension LightningRootViewViewModel {
    static func config() -> LightningRootViewViewModel {
        let btcAdapter = Portal.shared.adapterManager.adapter(for: .bitcoin())!
        return LightningRootViewViewModel(adapter: btcAdapter)
    }
}
