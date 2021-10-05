//
//  BinanceRequestConfig.swift
//  Portal
//
//  Created by Farid on 18/05/2019.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation
import CryptoSwift

public struct ExchangeCredentials {
    let name: String
    let key: String
    let secret: String
    let passphrase: String?
    let service: ExchangeService?
    
    init(name: String, key: String, secret: String, passphrase: String? = nil) {
        self.name = name
        
        self.key = key
        self.secret = secret
        self.passphrase = passphrase
        
        self.service = ExchangeService.with(name: self.name)
    }
    
    func balances(completion: @escaping (_ balances: [ExchangeBalanceModel], _ error: String?)->()) {
//        api.fetchBalance(credentials: self) { (balances, error) in
//            completion(balances, error)
//        }
    }
}

public enum ExchangeService: String {
    case binance
    case coinbasepro
    case kraken

    static func with(name: String) -> ExchangeService? {
        ExchangeService(rawValue: name)
    }
}

protocol BinanceRequestConfig {
    func configureBinanceRequest(_ params: Parameters?, credentials: ExchangeCredentials, request: inout URLRequest)
}

extension BinanceRequestConfig {
    func configureBinanceRequest(_ params: Parameters?, credentials: ExchangeCredentials, request: inout URLRequest) {
        let key = credentials.key
        let params = binanceParams(params, credentials: credentials)
        
        var queryString = params.queryString
        
        if let signature = params["signature"] {
            queryString += "&signature=\(signature)"
        }
        
        if var urlString = request.url?.absoluteString {
            urlString.append("?")
            urlString.append(queryString)
            let url = URL(string: urlString)
            request.url = url
        }
        
        request.setValue(key, forHTTPHeaderField: "X-MBX-APIKEY")
    }
    private func binanceParams(_ params: Parameters?, credentials: ExchangeCredentials) -> [String:String] {
        let secret = credentials.secret
        var parameters = [String:String]()
        
        if let initParams = params {
            for param in initParams {
                parameters[param.key] = "\(param.value)"
            }
        }
        
        parameters["timestamp"] = "\(Int(Date().timeIntervalSince1970 * 1000))"
        
        let queryString = parameters.queryString
        
        if let hmac_sha = try? HMAC(key: secret, variant: .sha256).authenticate(Array(queryString.utf8)) {
            let signature = Data(hmac_sha).toHexString()
            parameters["signature"] = signature
        }
        return parameters
    }
}
