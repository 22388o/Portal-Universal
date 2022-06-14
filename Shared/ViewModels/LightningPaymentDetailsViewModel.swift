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
    @Published var qrCode: UIImage?
    
    init(payment: LightningPayment) {
        self.payment = payment
        updateQRCode()
    }
    
    private func qrCode(invoice: String?) -> UIImage {
        guard let message = invoice?.data(using: .utf8) else { return UIImage() }
        
        let parameters: [String : Any] = [
            "inputMessage": message,
            "inputCorrectionLevel": "L"
        ]
        let filter = CIFilter(name: "CIQRCodeGenerator", parameters: parameters)
        
        guard let outputImage = filter?.outputImage else { return UIImage() }
        
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
        guard let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) else {
            return UIImage()
        }
        
        return UIImage(cgImage: cgImage, size: NSSize(width: 350, height: 350))
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
