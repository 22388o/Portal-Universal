//
//  BinancePrivateApi.swift
//  Portal
//
//  Created by Farid on 21/04/2019.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation

public enum BinancePrivateApi {
    case balances(credentials: ExchangeCredentials)
    case openOrders(credentials: ExchangeCredentials)
    case orders(credentials: ExchangeCredentials, symbol: String)
    case placeOrder(credentials: ExchangeCredentials, symbol: String, type: String, side: String, price: Double, quantity: Double)
    case cancelOrder(credentials: ExchangeCredentials, symbol: String, orderID: String)
    case depositAddress(credentials: ExchangeCredentials, asset: String)
    case withdraw(credentials: ExchangeCredentials, asset: String, address: String, amount: Double)
    case assetDetail(creadentials: ExchangeCredentials)
}

extension BinancePrivateApi: EndPointType {
    var headers: HTTPHeaders? { return nil }
    
    var environmentBaseURL: String {
        "https://testnet.binance.vision/api"
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    var path: String {
        switch self {
            //api calls
        case .balances:
            return "api/v3/account"
        case .orders:
            return "api/v3/allOrders"
        case .openOrders:
            return "api/v3/openOrders"
        case .placeOrder,
             .cancelOrder:
            return "api/v3/order"
            //wapi calls
        case .depositAddress:
            return "wapi/v3/depositAddress.html"
        case .withdraw:
            return "wapi/v3/withdraw.html"
        case .assetDetail:
            return "wapi/v3/assetDetail.html"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .balances,
             .depositAddress,
             .orders,
             .openOrders,
             .assetDetail:
            return .get
        case .placeOrder,
             .withdraw:
            return .post
        case .cancelOrder:
            return .delete
        }
    }
    
    var task: HTTPTask {
        var parameters = [String: Any]()
        var auth: ExchangeCredentials!
        
        switch self {
        case .balances(let credentials),
             .openOrders(let credentials),
             .assetDetail(let credentials):
            
            auth = credentials
            
        case .orders(let credentials, let symbol):
            
            auth = credentials
            parameters = ["symbol": symbol]

        case .depositAddress(let credentials, let asset):
            
            auth = credentials
            parameters = ["asset": asset]

        case .cancelOrder(let credentials, let symbol, let orderID):
            
            auth = credentials
            parameters = ["symbol": symbol, "orderId": orderID]

        case .placeOrder(let credentials, let symbol, let type, let side, let price, let quantity):
            
            auth = credentials
            
            parameters = [
                "symbol": symbol,
                "type": type,
                "side": side,
                "quantity": quantity
            ]
            
            if price > 0 { parameters["price"] = price }
            if type == "LIMIT" { parameters["timeInForce"] = "GTC" }
            
        case .withdraw(let credentials, let asset, let address, let amount):
            
            auth = credentials
            
            parameters = [
                "asset": asset,
                "address": address,
                "amount": amount
            ]
        }
        
        return .binanceSignedRequest(urlParameters: parameters, credentials: auth)
    }
}



