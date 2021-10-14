//
//  BinanceBalance.swift
//  Portal
//
//  Created by Farid on 05.10.2021.
//

import Foundation

public struct BinanceBalance: Decodable {
    public let asset: String
    public let free: String
    public let locked: String
}

