//
//  LightningPaymentDetailsViewModel.swift
//  Portal
//
//  Created by farid on 6/12/22.
//

import Combine
import SwiftUI

class LightningPaymentDetailsViewModel: ObservableObject {
    let payment: LightningPayment
    @Published var qrCode: Image?
    
    init(payment: LightningPayment) {
        self.payment = payment
        updateQRCode()
    }
    
    func qrCode(invoice: String) -> Image {
        guard let message = invoice.data(using: .utf8) else { return Image("cloud") }
        
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
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: 300, height: 300))
        return Image(nsImage: nsImage)
        #endif
    }
    
    private func updateQRCode() {
        guard let invoice = payment.invoice else { return }
        qrCode = qrCode(invoice: invoice)
    }
    
    func copyToClipboard() {
        guard let invoice = payment.invoice else { return }
#if os(iOS)
        UIPasteboard.general.string = String(invoice)
#else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(String(invoice), forType: NSPasteboard.PasteboardType.string)
#endif
    }
}
