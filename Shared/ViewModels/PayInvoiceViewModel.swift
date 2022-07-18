//
//  PayInvoiceViewModel.swift
//  Portal
//
//  Created by farid on 6/12/22.
//

import Combine
#if os(macOS)
import LDKFramework_Mac
#else
import LDKFramework
#endif
import NIOConcurrencyHelpers

class PayInvoiceViewModel: ObservableObject {
    @Published var invoiceString = String()
    @Published var invoice: Invoice?
    @Published var sent: Bool = false
    @Published var sendButtonAvaliable: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    private let channelManager: ChannelManager
    private let payer: InvoicePayer
    private let dataService: ILightningDataService
    private let notificationService: INotificationService
    
    var channelBalance: UInt64 {
        var balance: UInt64 = 0
        for channel in channelManager.list_usable_channels() {
            balance+=channel.get_balance_msat()/1000
        }
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
    
    init(dataService: ILightningDataService, channelManager: ChannelManager, payer: InvoicePayer, notificationService: INotificationService) {
        self.dataService = dataService
        self.notificationService = notificationService
        self.channelManager = channelManager
        self.payer = payer
        
        $invoiceString.sink { [weak self] invString in
            let result = Invoice.from_str(s: invString)
            if result.isOk() {
                self?.invoice = result.getValue()!
            }
        }
        .store(in: &subscriptions)
        
        $invoice.sink { [weak self] inv in
            guard let self = self, let _invoice = inv else { return }
            self.sendButtonAvaliable = !_invoice.is_expired() && self.channelBalance > (_invoice.amount_milli_satoshis().getValue()!/1000)
        }
        .store(in: &subscriptions)
    }
    
    func send() {
        guard let invoice = invoice else {
            return
        }

        guard !invoice.is_expired() else {
            print("invoice is expired")
            return
        }

        let amount = invoice.amount_milli_satoshis().getValue()!/1000
        print("amount \(amount) sat")

        let payee_pub_key = invoice.payee_pub_key().bytesToHexString()
        print(payee_pub_key)

        let network = invoice.currency()
        print(network)

        let payerResult = payer.pay_invoice(invoice: invoice)

        if payerResult.isOk() {
            print("invoice payed")
            let payment = LightningPayment(id: UUID().uuidString, satAmount: Int64(amount), created: Date(), description: "-", state: .sent)
            dataService.save(payment: payment)
            sent = true
        } else {
            if let error = payerResult.getError() {
                let notification: PNotification
                switch error.getValueType() {
                case .Invoice:
                    print("invoice error")
                    print("\(error.getValueAsInvoice()!)")
                    let error = error.getValueAsInvoice()!
                    notification = PNotification(message: "Invoice error: \(error)")
                case .Routing:
                    print("routing error")
                    print("\(error.getValueAsRouting()!.get_err())")
                    let error = error.getValueAsRouting()!.get_err()
                    notification = PNotification(message: "Routing error: \(error)")
                case .Sending:
                    print("sending error")
                    print("\(error.getValueAsSending()!)")
                    let error = error.getValueAsSending()!
                    notification = PNotification(message: "Sending error: \(error)")
                case .none:
                    print("unknown error")
                    notification = PNotification(message: "unknown invoice payer error")
                }
//                notificationService.notify(notification)
            }
        }
    }
}

extension PayInvoiceViewModel {
    static func config() -> PayInvoiceViewModel {
        guard let manager = Portal.shared.lightningService?.manager.channelManager else {
            fatalError("\(#function) channel manager :/")
        }
        guard let dataService = Portal.shared.lightningService?.dataService else {
            fatalError("\(#function) data service :/")
        }
        guard let payer = Portal.shared.lightningService?.manager.payer else {
            fatalError("\(#function) invoice payer :/")
        }
        let notificationService = Portal.shared.notificationService
        
        return PayInvoiceViewModel(
            dataService: dataService,
            channelManager: manager,
            payer: payer,
            notificationService: notificationService
        )
    }
}
