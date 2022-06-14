//
//  String+Extension.swift
//  Portal
//
//  Created by Farid on 11/30/21.
//

import Foundation

extension String {
    var reversed: String {
        let inputStringReversed = String(self.reversed())
        let characters = Array(inputStringReversed)
        var output = String()
        
        for i in 0...characters.count - 1 {
            if i % 2 == 0 {
                if (i+1) < characters.count {
                    output.append(characters[i + 1])
                }
                output.append(characters[i])
            }
        }
        
        return output
    }
    
    func timestamp() -> TimeInterval {
        TimeInterval(exactly: self.doubleValue) ?? 0
    }
    
    func hexStringToBytes() -> [UInt8]? {
        let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

        guard hexStr.count % 2 == 0 else { return nil }

        var newData = [UInt8]()

        var indexIsEven = true
        for i in hexStr.indices {
            if indexIsEven {
                let byteRange = i...hexStr.index(after: i)
                guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
                newData.append(byte)
            }
            indexIsEven.toggle()
        }
        return newData
    }
}
