//
//  IQRCodeProvider.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI

protocol IQRCodeProvider {
    func code(for address: String?) -> Image
}

extension IQRCodeProvider {
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
}
