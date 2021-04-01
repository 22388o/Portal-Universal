//
//  StringFormatter.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

struct StringFormatter {
    static func percentFormatted(_ amount: Double) -> String {
        String(format:" (%.2f", amount) + "%)"
    }

    static func localizedValueString(value: Double, symbol: String? = "$") -> String {
        let formatter = NumberFormatter()
        formatter.currencySymbol = symbol
        formatter.groupingSize = 3
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2 //value < 1 ? 2 : 0
        formatter.minimumFractionDigits = 1
        formatter.minimumIntegerDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "#"
    }

    static func changeString(price: Double, change: Double, currency: Currency) -> String {
        switch currency {
        case .btc, .eth:
            return changeString(price: price, change: change, currency: currency.stringValue())
        case .fiat(let currency):
            return changeString(price: price * currency.rate, change: change, currency: currency.symbol ?? "$")
        }
    }

    static func changeString(price: Double, change: Double, currency: String) -> String {
        let changeValue = (price * change)/100
        var outputString = String()

        if currency.contains("BTC") || currency.contains("ETH") {
            if changeValue > 0 {
                outputString = "+" + changeValue.roundToDecimal(3).toString()
            } else if changeValue == 0 {
                outputString = changeValue.roundToDecimal(3).toString()
            } else {
                outputString = "-" + abs(changeValue).roundToDecimal(3).toString()
            }
            outputString.append(" \(currency)")
        } else {
            let formatter = NumberFormatter()
            formatter.currencySymbol = currency
            formatter.numberStyle = .currency
            
            let value = change < 0 ? NSNumber(value: abs(changeValue)) : NSNumber(value: changeValue)
            
            if let currencyFormattedString = formatter.string(from: value) {
                if change > 0 {
                    outputString =  "+\(currencyFormattedString)"
                } else if change == 0 {
                    outputString = "\(currencyFormattedString)"
                } else {
                    outputString = "-\(currencyFormattedString)"
                }
            }
        }
        return outputString + percentFormatted(change)
    }

    static func totalValueString(value: Double, currency: Currency) -> String {
        switch currency {
        case .btc:
            return value.btcFormatted()
        case .eth:
            return value.ethFormatted()
        case .fiat(let currency):
            return localizedValueString(value: value * currency.rate, symbol: currency.symbol)
        }
    }
    
    static func roundBalanceString(value: Double, symbol: String) -> String {
        var roundedString = String(format: "%.6f", value)
        while roundedString.last == "." || roundedString.last == "0" {
            let isLast = roundedString.last == "."
            roundedString = String(roundedString.dropLast())
            if isLast { break }
        }
        return roundedString + " " + symbol
    }
    
    static func format(timestamp: String, shortFormat: Bool = false) -> String {
        let unixtimeInterval = Double(timestamp) ?? 0.0
        let date = Date(timeIntervalSince1970: unixtimeInterval)
        return format(date: date, shortFormat: shortFormat)
    }
        
    static func format(timestamp: Double, shortFormat: Bool = false) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        return format(date: date, shortFormat: shortFormat)
    }
    
    static func format(date: Date, shortFormat: Bool = false) -> String {
        date.timeAgoSinceDate(shortFormat: shortFormat)
    }
    
    static func format(number: Double) -> String {
        var format = "%.8f"
        number > 10 ? (format = "%.2f") : (format = "%.8f")
        return format
    }
}
