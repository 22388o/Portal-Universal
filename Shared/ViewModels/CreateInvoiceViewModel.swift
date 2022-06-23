//
//  CreateInvoiceViewModel.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import Foundation
import SwiftUI
import Combine
import Coinpaprika
#if os(iOS)
import LDKFramework
#elseif os(macOS)
import LDKFramework_Mac
#endif

class CreateInvoiceViewModel: ObservableObject {
    @Published var memo: String = ""
    @Published var qrCode: Image?
    @Published var invoiceString = String()
    @Published var showShareSheet: Bool = false
    @Published var fiatValue = String()
    @Published var satAmount = String()
    @Published var invoice: Invoice?
    @Published var createButtonAvaliable: Bool = false
    
    @Published var expireDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    
    private let service: ILightningService
    private var subscriptions = Set<AnyCancellable>()
    
    var pickerDateRange: ClosedRange<Date> {
        let anHourFromNow = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let aYearFromNow = Calendar.current.date(byAdding: .year, value: 1, to: Date())!

        return anHourFromNow...aYearFromNow
    }

    private var btcAdapter: IAdapter?
    
    init(service: ILightningService, ticker: Ticker?) {
        let price = ticker?[.usd].price
        
        self.service = service
        
        $satAmount
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { value in
                "\(((value * (price?.double ?? 1.0))/1_000_000).rounded(toPlaces: 2))"
            }
            .sink { [weak self] value in
                if value == "0.0" {
                    self?.fiatValue = "0"
                    self?.createButtonAvaliable = false
                } else {
                    self?.fiatValue = value
                    self?.createButtonAvaliable = true
                }
            }
            .store(in: &subscriptions)
    }
        
    var expires: Date? {
        guard let inv = invoice else { return nil }
        let expiteTime = TimeInterval(inv.expiry_time())
        return Date(timeInterval: expiteTime, since: Date())
    }
    
    func code(for address: String?) -> Image {
        guard let message = address?.data(using: .utf8) else { return Image("cloud") }
        
        let parameters: [String : Any] = [
                    "inputMessage": message,
                    "inputCorrectionLevel": "L"
                ]
        let filter = CIFilter(name: "CIQRCodeGenerator", parameters: parameters)
        
        guard let outputImage = filter?.outputImage else { return Image("cloud") }
               
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
        guard let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) else {
            return Image("cloud")
        }
        
        #if os(iOS)
        let uiImage = UIImage(cgImage: cgImage)
        return Image(uiImage: uiImage)
        #elseif os(macOS)
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: 150, height: 150))
        return Image(nsImage: nsImage)
        #endif
    }
    
    func createInvoice() {
        if let invoice = service.createInvoice(amount: satAmount, memo: memo) {
            invoiceString = invoice
            qrCode = code(for: invoice)

            self.invoice = Invoice.from_str(s: invoice).getValue()!
        }
    }
    
    func copyToClipboard() {
#if os(iOS)
        UIPasteboard.general.string = String(invoiceString)
#else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(String(invoiceString), forType: NSPasteboard.PasteboardType.string)
#endif
    }
}

extension CreateInvoiceViewModel {
    static func config() -> CreateInvoiceViewModel {
        guard let service = Portal.shared.lightningService else {
            fatalError("\(#function) lightning service :/")
        }
        let btcTicker = Portal.shared.marketDataProvider.ticker(coin: .bitcoin())
        
        return CreateInvoiceViewModel(service: service, ticker: btcTicker)
    }
}
