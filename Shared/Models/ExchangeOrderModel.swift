//
//  ExchangeOrderModel.swift
//  Portal
//
//  Created by Farid on 01.09.2021.
//

import Foundation

struct ExchangeOrderModel: Codable {
    let id: String
    let service: String
    let timestamp: Double
    let symbol: String?
    let type: String?
    let side: String
    let price: String
    let amount: String
    let cost: Decimal?
    let status: String
    
    enum Keys: String, CodingKey {
        case id, timestamp, symbol, type, side
        case price, amount, cost, status
    }
        
    init(order: BinanceOrder) {
        id = String(order.orderId)
        //binance timstamp is in milliseconds, so devide by 1000
        timestamp = order.time/1000
        price = order.price
        side = order.side
        amount = order.origQty
        
        symbol = order.symbol
        type = order.type
        cost = nil
        
        if order.status == "NEW" {
            status = "open"
        } else {
            status = order.status
        }
        
        service = "binance"
    }
    
    init(order: BittrexOpenOrder) {
        id = order.orderUuid
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        
        if let date = dateFormatter.date(from: order.opened)?.timeIntervalSince1970 {
            timestamp = Double(date)
        } else {
            timestamp = 0.0
        }
        
        price = String(format: "%f", order.limit)
        side = order.orderType
        
        amount = String(order.quantity)
        
        symbol = order.exchange
        type = order.orderType
        cost = nil
        status = order.closed == nil ? "open" : "closed"
        service = "bittrex"
    }
    
    init(order: CoinbaseOrder) {
        id = order.id
        
        if let priceDouble = order.funds?.doubleValue, priceDouble > 0 {
            price = String(format: "%f", priceDouble)
        } else if let priceDouble = order.executedValue?.doubleValue, priceDouble > 0 {
            price = String(format: "%f", priceDouble)
        } else if let priceDouble = order.price?.doubleValue, priceDouble > 0  {
            price = String(format: "%f", priceDouble)
        } else {
            price = "market"
        }
    
        side = order.side
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
        
        if let date = dateFormatter.date(from: order.timestamp)?.timeIntervalSince1970 {
            timestamp = Double(date)
        } else {
            timestamp = 0.0
        }
        
        status = order.status == "open" ? "open" : "closed"
        
        amount = order.size
        
        symbol = order.productID
        type = order.type
        cost = nil
        service = "coinbasepro"
    }
    
    init(order: KrakenOrderHistoryTrade) {
        id = order.ordertxid
        timestamp = order.time
        price = order.price
        side = order.type
        amount = order.vol
        
        symbol = order.pair
        type = order.ordertype
        cost = Decimal(order.cost.doubleValue)
        status = "closed"
        service = "kraken"
    }
    
    init(order: KrakenOpenOrdersTrade, txid:String) {
        id = txid
        timestamp = order.opentm
        price = order.descr.price
        side = order.descr.type
        amount = order.vol
        
        symbol = order.descr.pair
        type = order.descr.ordertype
        cost = Decimal(order.cost.doubleValue)
        status = "open"
        service = "kraken"
    }
}

struct BinanceOrder: Codable {
    let symbol: String
    let orderId: UInt64
    let clientOrderId: String
    let price: String
    let origQty: String
    let executedQty: String
    let status: String
    let timeInForce: String
    let type: String
    let side: String
    let stopPrice: String
    let icebergQty: String
    let time: Double
    let isWorking: Bool
}

public struct BittrexOpenOrder: Decodable {
    public let uuid: String?
    public let orderUuid: String
    public let exchange: String
    public let orderType: String
    public let quantity: Double
    public let quantityRemaining: Double
    public let limit: Double
    public let commissionPaid: Double
    public let price: Double
    public let pricePerUnit: Double?
    public let opened: String
    public let closed: String?
    public let cancelInitiated: Bool
    public let immediateOrCancel: Bool
    public let isConditional: Bool
    public let condition: String?
    public let conditionTarget: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid = "Uuid"
        case orderUuid = "OrderUuid"
        case exchange = "Exchange"
        case orderType = "OrderType"
        case quantity = "Quantity"
        case quantityRemaining = "QuantityRemaining"
        case limit = "Limit"
        case commissionPaid = "CommissionPaid"
        case price = "Price"
        case pricePerUnit = "PricePerUnit"
        case opened = "Opened"
        case closed = "Closed"
        case cancelInitiated = "CancelInitiated"
        case immediateOrCancel = "ImmediateOrCancel"
        case isConditional = "IsConditional"
        case condition = "Condition"
        case conditionTarget = "ConditionTarget"
    }
}

public struct CoinbaseOrder: Decodable {
    let id: String
    let funds: String?
    let price: String?
    let executedValue: String?
    let size: String
    let productID: String
    let side: String
    let type: String
    let timestamp: String
    let status: String
    let settled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case price
        case funds
        case size
        case executedValue = "executed_value"
        case productID = "product_id"
        case side
        case type
        case timestamp = "created_at"
        case status
        case settled
    }
}

public struct KrakenOrderHistoryTrade: Decodable {
    public let ordertxid:String
    public let pair: String
    public let time: Double
    public let type: String
    public let ordertype: String
    public let price: String
    public let cost: String
    public let fee: String
    public let vol: String
    public let margin: String
    public let misc: String

    enum CodingKeys: String, CodingKey {
        case ordertxid = "ordertxid"
        case pair = "pair"
        case time = "time"
        case type = "type"
        case ordertype = "ordertype"
        case price = "price"
        case cost = "cost"
        case fee = "fee"
        case vol = "vol"
        case margin = "margin"
        case misc = "misc"
    }
}

public struct KrakenOpenOrdersTrade: Decodable {
    public let cost:String
    public let status:String
    public let opentm: Double
    public let vol: String
    public let descr: KrakenOpenOrderDesc
    
    enum CodingKeys: String, CodingKey {
        case cost = "cost"
        case status = "status"
        case opentm = "opentm"
        case vol = "vol"
        case descr = "descr"
    }
}

public struct KrakenOpenOrderDesc: Decodable {
    public let ordertype:String
    public let pair: String
    public let price: String
    public let type: String
    
    
    enum CodingKeys: String, CodingKey {
        case ordertype = "ordertype"
        case pair = "pair"
        case price = "price"
        case type = "type"
    }
}

extension String {
    /// "0.9" => 0.9
    var doubleValue: Double {
        Double(self) ?? 0
    }
}

