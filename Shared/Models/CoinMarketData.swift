//
//  CoinMarketData.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

struct CoinMarketData {
    var priceData: MarketPrice?
    
    var hourPoints = [Decimal]()
    var dayPoints = [Decimal]()
    var weekPoints = [Decimal]()
    var monthPoints = [Decimal]()
    var yearPoints = [Decimal]()
    
    var dayOhlc = [MarketSnapshot]()
    
    var hasData: Bool = true
    
    func price(currency: Currency) -> Decimal {
        return 0.0
    }
    
    func priceString(currency: Currency) -> String {
        switch currency {
        case .btc:
            return priceData?.price.double.btcFormatted() ?? 0.0.btcFormatted()
        case .eth:
            return priceData?.price.double.ethFormatted() ?? 0.0.ethFormatted()
        case .fiat(let currency):
            let value = (priceData?.price ?? 0.0) * Decimal(currency.rate)
            return StringFormatter.localizedValueString(value: value, symbol: currency.symbol)
        }
    }
    
    func changeInPercents(tf: Timeframe) -> Decimal {
        switch tf {
        case .day:
            return dayChange
        case .week:
            return weekChange
        case .month:
            return monthChange
        case .year:
            return yearChange
        }
    }
    
    func changeString(for timeframe: Timeframe, currrency: Currency) -> String {
        let price = price(currency: currrency)
        let change = changeInPercents(tf: timeframe)

        return StringFormatter.changeString(price: price, change: change, currency: currrency)
    }
    
    var dayChange: Decimal {
        guard
            let open = dayPoints.first,
            let close = dayPoints.last
            else { return 0.0 }

        return percentageChange(open: open, close: close)
    }

    var weekChange: Decimal {
        guard
            let open = weekPoints.first,
            let close = weekPoints.last
            else { return 0.0 }

        return percentageChange(open: open, close: close)
    }

    var monthChange: Decimal {
        guard
            let open = monthPoints.first,
            let close = monthPoints.last
            else { return 0.0 }

        return percentageChange(open: open, close: close)
    }

    var yearChange: Decimal {
        guard
            let open = yearPoints.first,
            let close = yearPoints.last
            else { return 0.0 }

        return percentageChange(open: open, close: close)
    }
    
    var dayHigh: Decimal {
        dayPoints.sorted(by: { $0 > $1 }).first ?? 0.0
    }

    var dayLow: Decimal {
        dayPoints.sorted(by: { $0 < $1 }).first ?? 0.0
    }

    var weekHigh: Decimal {
        weekPoints.sorted(by: { $0 > $1 }).first ?? 0.0
    }

    var weekLow: Decimal {
        weekPoints.sorted(by: { $0 < $1 }).first ?? 0.0
    }

    var monthHigh: Decimal {
        monthPoints.sorted(by: { $0 > $1 }).first ?? 0.0
    }

    var monthLow: Decimal {
        monthPoints.sorted(by: { $0 < $1 }).first ?? 0.0
    }

    var yearHigh: Decimal {
        yearPoints.sorted(by: { $0 > $1 }).first ?? 0.0
    }

    var yearLow: Decimal {
        yearPoints.sorted(by: { $0 < $1 }).first ?? 0.0
    }
    
    private func percentageChange(open: Decimal, close: Decimal) -> Decimal {
        let decrease = close - open
        return (decrease/open) * 100
    }
}
