//
//  Double+Extension.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

extension Double {
    func dollarFormatted() -> String {
        StringFormatter.localizedValueString(value: self, symbol: "$")
    }
    func btcFormatted() -> String {
        roundToDecimal(3).toString() + " BTC"
    }
    func ethFormatted() -> String {
        roundToDecimal(3).toString() + " ETH"
    }
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    func toString(decimal: Int = 12) -> String {
        let value = decimal < 0 ? 0 : decimal
        var string = String(format: "%.\(value)f", self)
        
        while string.last == "0" || string.last == "." {
            if string.last == "." { string = String(string.dropLast()); break }
            string = String(string.dropLast())
        }
        if string == "0" {
            string = "0.00"
        }
        return string
    }
    
    func fiatFormatted(_ symbol: String? = "$") -> String {
        let formatter = NumberFormatter()
        formatter.currencySymbol = symbol
        formatter.groupingSize = 3
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2 //self < 1 ? 2 : 0
        formatter.minimumFractionDigits = 1
        formatter.minimumIntegerDigits = 1
        return formatter.string(from: NSNumber(value: self)) ?? "#"
    }
}


