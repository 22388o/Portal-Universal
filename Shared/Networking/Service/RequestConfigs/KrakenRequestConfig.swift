//
//  KrakenRequestConfig.swift
//  Portal
//
//  Created by Manoj Duggirala on 06/17/2019.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation
import CryptoSwift

protocol KrakenRequestConfig {
    func configureKrakenRequest(_ params: Parameters?, credentials: ExchangeCredentials, request: inout URLRequest, path:String)
}

extension KrakenRequestConfig {
    func configureKrakenRequest(_ params: Parameters?, credentials: ExchangeCredentials, request: inout URLRequest, path:String) {
        let key = credentials.key
        let secret = credentials.secret
        var params = krakenParams(params)
        let timestamp = NSDate().timeIntervalSince1970*1000
        let nonce = "\(Int64(timestamp))"
        params["nonce"] = nonce
        let queryString = params.queryString
        
        if let urlString = request.url?.absoluteString {
            let url = URL(string: urlString)
            request.url = url
            request.httpBody = queryString.utf8Data()
            
            let prehashBytes = Array(path.utf8)+SHA2(variant: .sha256).calculate(for: Array((nonce+queryString).utf8))
            if let bytes = Data(base64Encoded: secret)?.bytes,
            let hmac_sha = try? HMAC(key: bytes, variant: .sha512).authenticate(prehashBytes),
            let signature = hmac_sha.toBase64()
            {
                request.setValue(signature, forHTTPHeaderField: "API-Sign")
            }
            request.setValue(key, forHTTPHeaderField: "API-Key")

        }
        print(request)
    }
    
    private func krakenParams(_ params: Parameters?) -> [String:String] {
        var parameters = [String:String]()
        
        if let initParams = params {
            for param in initParams {
                parameters[param.key] = "\(param.value)"
            }
        }
        
        return parameters
    }

}

public extension String {
    func utf8Data() -> Data? {
        data(using: .utf8)
    }
}
