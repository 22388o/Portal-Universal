//
//  KrakenPrivateApi.swift
//  Portal
//
//  Created by Manoj Duggirala on 06/17/2019.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation

public enum KrakenPrivateApi {
    case assets(credentials: ExchangeCredentials)
    case balances(credentials: ExchangeCredentials)
    case orders(credentials: ExchangeCredentials)
    case openOrders(credentials: ExchangeCredentials)
    case placeOrder(credentials: ExchangeCredentials, symbol: String, price: Double, quantity: Double, ordertype: String, orderside: String)
    case cancelOrder(credentials: ExchangeCredentials, orderID: String)
    case withdraw(credentials: ExchangeCredentials, asset: String, amount: Double, key: String)
    case depositMethods(credentials: ExchangeCredentials, asset: String)
    case depositAddress(credentials: ExchangeCredentials, asset: String, method:String)
}

extension KrakenPrivateApi: EndPointType {
    var headers: HTTPHeaders? { nil }
    
    var environmentBaseURL: String {
        "https://api.kraken.com"
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .assets:
            return "/0/public/Assets"
        case .balances:
            return "/0/private/Balance"
        case .orders:
            return "/0/private/TradesHistory"
        case .openOrders:
            return "/0/private/OpenOrders"
        case .placeOrder:
            return "/0/private/AddOrder"
        case .cancelOrder:
            return "/0/private/CancelOrder"
        case .withdraw:
            return "/0/private/Withdraw"
        case .depositMethods:
            return "/0/private/DepositMethods"
        case .depositAddress:
            return "/0/private/DepositAddresses"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var task: HTTPTask {
        var parameters = [String: Any]()
        var auth: ExchangeCredentials!
        
        switch self {
        case .assets(let credentials),
             .balances(let credentials),
             .orders(let credentials),
             .openOrders(let credentials):
             
            auth = credentials
            
        case .placeOrder(let credentials, let symbol, let price, let quantity, let ordertype, let orderside):
            
            auth = credentials
            parameters = [
                "type":orderside,
                "ordertype":ordertype,
                "pair": symbol,
                "volume": quantity,
                "price": price
            ]
            
        case .cancelOrder(let credentials, let orderID):
            
            auth = credentials
            parameters = ["txid": orderID]
            
        case .withdraw(let credentials, let asset, let amount, let key):
            
            auth = credentials
            
            parameters = [
                "asset": asset,
                "amount": amount,
                "key": key
            ]
            
        case .depositAddress(let credentials, let asset, let method):
            
            auth = credentials
            parameters = ["asset": asset, "method": method]
            
        case .depositMethods(let credentials, let asset):
            auth = credentials
            parameters = ["asset": asset]
        }
        
        return .krakenSignedRequest(urlParameters: parameters, credentials: auth, path:path)
    }
}
