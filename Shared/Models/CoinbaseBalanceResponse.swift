//
//  CoinbaseBalanceResponse.swift
//  Portal
//
//  Created by Farid on 27.09.2021.
//

import Foundation

public struct CoinbaseBalancesResponse: Decodable {
    public let id: String
    public let currency: String
    public let balance: String
    public let available: String
    public let hold: String
    public let profileID: String
    
    
    public enum CodingKeys: String, CodingKey {
        case id
        case currency
        case balance
        case available
        case hold
        case profileID = "profile_id"
    }
}
