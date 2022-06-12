//
//  PayInvoiceViewModel.swift
//  Portal
//
//  Created by farid on 6/12/22.
//

import Combine
import LDKFramework_Mac

class PayInvoiceViewModel: ObservableObject {
    @Published var invoiceString = String()
    @Published var invoice: Invoice?
    @Published var sent: Bool = false
    private var subscriptions = Set<AnyCancellable>()
    
    var channelBalance: UInt64 {
        var balance: UInt64 = 0
        
//        for channel in PolarConnectionExperiment.shared.service!.manager.channelManager.list_usable_channels() {
//            balance+=channel.get_balance_msat()/1000
//        }
        
        return balance
    }
    
    var amountString: String? {
        guard let inv = invoice else { return "" }
        let amount = inv.amount_milli_satoshis().getValue()!/1000
        return "\(amount) sat"
    }
    
    var expires: String? {
        guard let inv = invoice else { return "" }
        let expiteTime = TimeInterval(inv.expiry_time())
        return "\(Date(timeInterval: expiteTime, since: Date()))"
    }
    
    var payeePubKey: String? {
        guard let inv = invoice else { return "" }
        return inv.payee_pub_key().bytesToHexString()
    }
    
    var networkString: String? {
        guard let inv = invoice else { return "" }

        switch inv.currency() {
        case LDKCurrency_Bitcoin:
            return "Bitcoin"
        case LDKCurrency_BitcoinTestnet:
            return "Bitcoin testnet"
        case LDKCurrency_Regtest:
            return "Bitcoin regtest"
        default:
            return "Bitcoin ?"
        }
    }
    
    func scan() {
        let result = Invoice.from_str(s: "lntb10200n1p3f58cspp5flky3wyhtajzpx37smjcce0cqj8d0ral9q8zm9hgph0qk54uajqqdqqcqzpgxqyz5vqsp5a90cd6an69xh057tvanwsdkecv3pc2tmtzl0g36fcyl9sy7p200s9qyyssqs9gdf7xqlee4f2kzq506fa38tumsjxu4fxly2mf4rs78cz5t2l7hc4zzte4zk3kcuestqxt2qkgm5farcz2a24thdjv8lxxt7hsqtfgq0mlw7c")
        if result.isOk() {
            invoice = result.getValue()!
        }
    }
    
    func send() {
//        guard let invoice = invoice else {
//            return
//        }
//
//        let expired = invoice.is_expired()
//
//        if expired {
//            print("invoice is expired")
//            return
//        }
//
//        let amount = invoice.amount_milli_satoshis().getValue()!/1000
//        print("amount \(amount) sat")
//
//        let payee_pub_key = LDKBlock.bytesToHexString(bytes: invoice.payee_pub_key())
//        print(payee_pub_key)
//
//        let network = invoice.currency()
//        print(network)
//
//        let payer = PolarConnectionExperiment.shared.service!.manager.payer!
//
//        let payerResult = payer.pay_invoice(invoice: invoice)
//
//        if payerResult.isOk() {
//            print("invoice payed")
//            let payment = LightningPayment(id: UUID().uuidString, satAmount: Int64(amount), created: Date(), memo: "-", state: .sent)
//            PolarConnectionExperiment.shared.service?.dataService.save(payment: payment)
//            sent = true
//        } else {
//            if let error = payerResult.getError() {
//                switch error.getValueType() {
//                case .Invoice:
//                    print("invoice error")
//                    print("\(error.getValueAsInvoice()!)")
//                    let error = error.getValueAsInvoice()!
//                    PolarConnectionExperiment.shared.userMessage = "Invoice error: \(error)"
//                case .Routing:
//                    print("routing error")
//                    print("\(error.getValueAsRouting()!.get_err())")
//                    let error = error.getValueAsRouting()!.get_err()
//                    PolarConnectionExperiment.shared.userMessage = "Routing error: \(error)"
//                case .Sending:
//                    print("sending error")
//                    print("\(error.getValueAsSending()!)")
//                    let error = error.getValueAsSending()!
//                    PolarConnectionExperiment.shared.userMessage = "Sending error: \(error)"
//                case .none:
//                    print("unknown error")
//                }
//            }
//        }
    }
}
