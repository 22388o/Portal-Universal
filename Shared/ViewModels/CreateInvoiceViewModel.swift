//
//  CreateInvoiceViewModel.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import Foundation
import SwiftUI
import Combine

class CreateInvoiceViewModel: ObservableObject {
    @Published var memo: String = ""
    @Published var qrCode: UIImage?
    @Published var invoiceString = String()
    @Published var showShareSheet: Bool = false
    @Published var fiatValue = String()
    @Published var satAmount = String()
//    @Published var invoice: Invoice?
    
    @Published var expireDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    
    private var subscriptions = Set<AnyCancellable>()
    
    var pickerDateRange: ClosedRange<Date> {
        let anHourFromNow = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let aYearFromNow = Calendar.current.date(byAdding: .year, value: 1, to: Date())!

        return anHourFromNow...aYearFromNow
    }

    private var btcAdapter: IAdapter?
    
    init() {
        let btc = Coin.bitcoin()
        let ticker = Portal.shared.marketDataProvider.ticker(coin: btc)
        let price = ticker?[.usd].price
        
        $satAmount
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { value in
                "\(((value * (price?.double ?? 1.0))/1_000_000).rounded(toPlaces: 2))"
            }
            .sink { [weak self] value in
                if value == "0.0" {
                    self?.fiatValue = "0"
                } else {
                    self?.fiatValue = value
                }
            }
            .store(in: &subscriptions)
    }
        
    var expires: Date {
        Date()
//        let expiteTime = TimeInterval(invoice!.expiry_time())
//        return Date(timeInterval: expiteTime, since: Date())
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
//        if let invoice = PolarConnectionExperiment.shared.service?.createInvoice(amount: exchangerViewModel.assetValue, memo: memo) {
//            invoiceString = invoice
//            qrCode = qrCode(address: invoice)
//
//            self.invoice = Invoice.from_str(s: invoice).getValue()!
//        }
    }
}
