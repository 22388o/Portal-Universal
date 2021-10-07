//
//  SocketTicker.swift
//  Portal
//
//  Created by Farid on 28.09.2021.
//

import Foundation

struct SocketTicker: Equatable {
    let change: String
    let last: String
    let high: String
    let low: String
    let volume: String
    
    init(data: NSDictionary?, base: String?, quote: String?) {
        guard
            let state = data,
            let changeString = state["change"] as? String,
            let lastString = state["last"] as? String,
            let highestString = state["high"] as? String,
            let lowestString = state["low"] as? String,
            let volumeString = state["volume"]  as? String,
            let _base = base,
            let _quote = quote
        else {
            
            change = "-"
            last = "-"
            high = "-"
            low = "-"
            volume = "-"
            
            return
        }
        
        change = String(format: "%.8f", Double(changeString) ?? "-")
        last = String(format: "%.8f", Double(lastString) ?? "-")
        high = String(format: "%.8f", Double(highestString) ?? "-")
        low = String(format: "%.8f", Double(lowestString) ?? "-")
        
        if let quoteVolume = state["quoteVolume"] as? String {
            volume = String(format: "%.3f", Double(quoteVolume) ?? 0.0) + " \(_quote)"
        } else {
            volume = String(format: "%.3f", Double(volumeString) ?? 0.0) + " \(_base)"
        }
    }
}
