//
//  IBalanceProvider.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

protocol IBalanceProvider {
    func balance(currency: Currency) -> Double
    var balanceString: String { get }
    var totalValueString: String { get }
    var price: String { get }
}
