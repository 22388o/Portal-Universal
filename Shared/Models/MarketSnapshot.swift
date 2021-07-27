//
//  MarketSnapshot.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Coinpaprika

struct MarketSnapshot {
    let high: Decimal
    let low: Decimal
    let open: Decimal
    let close: Decimal
    
    init(_ ohlc: Coinpaprika.Ohlcv) {
        high = ohlc.high ?? 0
        low = ohlc.low ?? 0
        open = ohlc.open ?? 0
        close = ohlc.close ?? 0
    }
}

