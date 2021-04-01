//
//  MarketChangeProvider.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

final class MarketChangeProvider: IMarketChangeProvider {
    let tempChange: String = "+$\(Double.random(in: 12..<480).rounded(toPlaces: 1)) (\(Double.random(in: 2.5..<15).rounded(toPlaces: 1))%)"
    var changeString: String {
        tempChange
    }
}
