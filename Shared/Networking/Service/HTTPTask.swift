//
//  HTTPTask.swift
//  Portal
//
//  Created by Farid on 12/09/2018.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String:String]

public enum HTTPTask {
    case request
    
    case binanceSignedRequest(
        urlParameters: Parameters?,
        credentials: ExchangeCredentials
    )
    
    case coinbaseProSignedRequest(
        urlParameters: Parameters?,
        credentials: ExchangeCredentials,
        path: String
    )
    
    case krakenSignedRequest(
        urlParameters: Parameters?,
        credentials: ExchangeCredentials,
        path: String
    )
    
    case requestParameters(
        bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?
    )
    
    case requestParametersAndHeaders(
        bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?
    )
}


