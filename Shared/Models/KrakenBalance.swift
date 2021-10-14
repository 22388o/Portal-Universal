//
//  KrakenBalance.swift
//  Portal
//
//  Created by Farid on 27.09.2021.
//

import Foundation

public struct KrakenBalance: Decodable {
    public let asset: String
    public let free: Double
    public let locked: Double
}
