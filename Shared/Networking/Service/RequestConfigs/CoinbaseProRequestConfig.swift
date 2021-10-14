//
//  CoinbaseProRequestConfig.swift
//  Portal
//
//  Created by Farid on 18/05/2019.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation
import CryptoSwift

protocol CoinbaseProRequestConfig {
    func configureCoinbaseProRequest(_ params: Parameters?, credentials: ExchangeCredentials, path: String, request: inout URLRequest)
}

extension CoinbaseProRequestConfig {
    func configureCoinbaseProRequest(_ params: Parameters?, credentials: ExchangeCredentials, path: String, request: inout URLRequest) {
        guard let passphrase = credentials.passphrase else { return }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let key = credentials.key
        request.setValue(key, forHTTPHeaderField: "CB-ACCESS-KEY")
        request.setValue(passphrase, forHTTPHeaderField: "CB-ACCESS-PASSPHRASE")
        
        let timestamp = Int64(Date().timeIntervalSince1970)
        request.setValue("\(timestamp)", forHTTPHeaderField: "CB-ACCESS-TIMESTAMP")
        
        let method = request.httpMethod ?? "get"
        let relativeURL = "/" + path
        
        let body = method == "POST" ? generateBody(withParameters: params) : nil
        
        let sign = try? signature(
            secret: credentials.secret,
            timestamp: timestamp,
            method: method,
            relativeURL: relativeURL,
            body: body,
            params: params
        )
        
        if let signature = sign {
            request.setValue(signature, forHTTPHeaderField: "CB-ACCESS-SIGN")
        }
        
        if var urlString = request.url?.absoluteString {
            guard method != "POST" else {
                
                if let body = generateBody(withParameters: params) {
                    request.httpBody = body.data(using: .utf8)
                }
                
                let url = URL(string: urlString)
                request.url = url
                
                return
            }
            
            var p = [String: String]()
            
            for param in params! {
                p[param.key] = "\(param.value)"
            }

            let queryString = p.queryString

            if !queryString.isEmpty {
                urlString.append("?")
                urlString.append(queryString)
            }

            let url = URL(string: urlString)
            request.url = url
        }
    }
    
    private func signature(secret: String, timestamp: Int64, method: String, relativeURL: String, body: String?, params: Parameters?) throws -> String {
        
        var preHash: String = ""
        var components = URLComponents(string: relativeURL)
        
        preHash = "\(timestamp)\(method.uppercased())\(relativeURL)" + (body ?? "")

        if let bodyParams = params, !bodyParams.keys.isEmpty {
            if !bodyParams.isEmpty && method == "GET" {
                var queryItems = [URLQueryItem]()
                for param in bodyParams {
                    if let p = param.value as? String {
                        queryItems.append(URLQueryItem(name: param.key, value: p))
                    }
                }
                components?.queryItems = queryItems

                if let request = URL(string: components?.string ?? "") {
                    preHash = "\(timestamp)\(method.uppercased())\(request.absoluteString)" + (body ?? "")
                }
            }
        }
        
        guard let secret = Data(base64Encoded: secret) else {
            throw CoinbaseSwiftError.authenticationBuilderError("Failed to base64 decode secret")
        }
        
        guard let preHashData = preHash.data(using: .utf8) else {
            throw CoinbaseSwiftError.authenticationBuilderError("Failed to convert preHash into data")
        }
        
        guard let hmac = try HMAC(key: secret.bytes, variant: .sha256).authenticate(preHashData.bytes).toBase64() else {
            throw CoinbaseSwiftError.authenticationBuilderError("Failed to generate HMAC from preHash")
        }
        
        return hmac
    }
    
    private func generateBody(withParameters parameters: Parameters?) -> String? {
        guard let params = parameters, !params.keys.isEmpty else { return nil }
        if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []) {
            return String(data: jsonData, encoding: String.Encoding.ascii)
        }
        return nil
    }
}

extension Array where Element == UInt8 {
    public func toBase64() -> String? {
        Data(self).base64EncodedString()
    }
    var data : Data {
        Data(self)
    }
    public init(base64: String) {
        self.init()
        
        guard let decodedData = Data(base64Encoded: base64) else {
            return
        }
        
        append(contentsOf: decodedData.bytes)
    }
}


public enum CoinbaseSwiftError: Error, LocalizedError {
    
    case authenticationBuilderError(String)
    case responseParsingFailure(String)
    
    public var errorDescription: String? {
        switch self {
        case .authenticationBuilderError(let message):
            return NSLocalizedString(message, comment: "error")
        case .responseParsingFailure(let message):
            return NSLocalizedString(message, comment: "error")
        }
    }
}
