//
//  CoinbaseProPrivateApi.swift
//  Portal
//
//  Created by Farid on 15/05/2019.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation

public enum CoinbaseProPrivateApi {
    case coinbaseAccounts(credentials: ExchangeCredentials)
    case balances(credentials: ExchangeCredentials)
    case orders(credentials: ExchangeCredentials, symbol: String)
    case placeOrder(credentials: ExchangeCredentials, symbol: String, type: String, side: String, price: Double, quantity: Double)
    case cancelOrder(credentials: ExchangeCredentials, symbol: String, orderID: String)
    case withdraw(credentials: ExchangeCredentials, asset: String, address: String, amount: Double)
    case depositAddress(credentials: ExchangeCredentials, id: String)
}

extension CoinbaseProPrivateApi: EndPointType {
    var environmentBaseURL : String {
        "https://api-public.sandbox.pro.coinbase.com"
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.") }
        return url
    }
    
    var path: String {
        switch self {
        case .balances:
            return "accounts"
        case .placeOrder, .orders:
            return "orders"
        case .cancelOrder(_, _, let orderID):
            return "orders/\(orderID)"
        case .withdraw:
            return "withdrawals/crypto"
        case .coinbaseAccounts:
            return "coinbase-accounts"
        case .depositAddress(_, let id):
            return "coinbase-accounts/\(id)/addresses"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .coinbaseAccounts,
             .balances,
             .orders:
            return .get
        case .placeOrder,
             .withdraw,
             .depositAddress:
            return .post
        case .cancelOrder:
            return .delete
        }
    }
    
    var task: HTTPTask {
        var parameters = [String: Any]()
        var auth: ExchangeCredentials!
        
        switch self {
        case .coinbaseAccounts(let credentials), .balances(let credentials):
            auth = credentials
        case .orders(let credentials, let symbol):
            auth = credentials
            
            if !symbol.isEmpty {
                parameters = ["status": "all", "product_id": symbol]
            } else {
                parameters = ["status": "all"]
            }
            
        case .placeOrder(let credentials, let symbol, let type, let side, let price, let quantity):
            auth = credentials
            
            parameters = [
                "side": side,
                "type": type,
                "product_id": symbol,
                "size": quantity
            ]

            if type == "limit" {
                parameters["price"] = price
            }
        case .cancelOrder(let credentials, _, _):
            auth = credentials
        case .withdraw(let credentials, let asset, let address, let amount):
            auth = credentials
            
            parameters = [
                "amount": amount,
                "currency": asset,
                "crypto_address": address
            ]
        case .depositAddress(let credentials, _ ):
            auth = credentials
        }
        
        return .coinbaseProSignedRequest(urlParameters: parameters, credentials: auth, path: path)
    }
    
    var headers: HTTPHeaders? { nil }
}
