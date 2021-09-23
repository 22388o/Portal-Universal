//
//  SocketOrderBook.swift
//  Portal
//
//  Created by Farid on 30.08.2021.
//

import Foundation

struct SocketOrderBook {
    let bids: [SocketOrderBookItem]
    let asks: [SocketOrderBookItem]
    
    init(dataDict: NSDictionary) {
        guard
            let rawBids = dataDict["bids"] as? [[String : String]],
            let rawAsks = dataDict["asks"] as? [[String : String]]
        else {
            bids = []
            asks = []
            return
        }
        
        let price = "price"
        let size = "size"
        let empty = ""
        
        bids = rawBids.map{
            SocketOrderBookItem(
                price: Double($0[price] ?? empty) ?? 0.0,
                amount: Double($0[size] ?? empty) ?? 0.0
            )}.filter{$0.amount > 0.0}//.unique{$0.price}
        
        asks = rawAsks.map{
            SocketOrderBookItem(
                price: Double($0[price] ?? empty) ?? 0.0,
                amount: Double($0[size]  ?? empty)  ?? 0.0
            )}.filter{$0.amount > 0.0}//.unique{$0.price}
    }
}
