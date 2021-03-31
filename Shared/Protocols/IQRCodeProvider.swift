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
    func qrCode(address: String?) -> UIImage
}

extension IQRCodeProvider {
    func qrCode(address: String?) -> UIImage {
        guard let message = address?.data(using: .utf8) else { return UIImage() }
        
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
        
        return UIImage(cgImage: cgImage)
    }
}
