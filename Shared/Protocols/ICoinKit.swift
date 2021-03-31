//
//  ICoinKit.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

protocol ICoinKit {
    var balance: Double { get }
    func send(amount: Double)
}

extension ICoinKit {
    var balance: Double {
        Double.random(in: 0.0125..<2.1234).rounded(toPlaces: 2)
    }
}
