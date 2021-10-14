//
//  CoinbaseAccount.swift
//  Portal
//
//  Created by Farid on 27.09.2021.
//

import Foundation

public struct CoinbaseAccount: Codable {
    let id: String
    let name: String
    let balance: String
    let currency: String
    let type: String
    let primary: Bool
    let active: Bool
}

public struct CoinbaseWithdrawResponse: Codable {
    let id: String
    let amount: String
    let currency: String
}
