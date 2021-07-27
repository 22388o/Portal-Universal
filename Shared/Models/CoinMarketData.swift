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
//        switch tf {
//        case .hour:
//            return hourChange
//        case .day:
//            return dayChange
//        case .week:
//            return weekChange
//        case .month:
//            return monthChange
//        case .year:
//            return yearChange
//        case .allTime:
            return 0.0
//        }
    }
    
    func changeString(for timeframe: Timeframe, currrency: Currency) -> String {
        let price = self.price(currency: currrency)
        let change = self.changeInPercents(tf: timeframe) 

        return StringFormatter.changeString(price: price, change: change, currency: currrency)
    }
    
//    var hourChange: Decimal {
//        guard
//            let open = hourPoints.first?.open,
//            let close = hourPoints.last?.close
//            else { return 0.0 }
//
//        return percentageChange(open: open, close: close)
//    }
//
//    var dayChange: Decimal {
//        guard
//            let open = dayPoints.first?.open,
//            let close = dayPoints.last?.close
//            else { return 0.0 }
//
//        return percentageChange(open: open, close: close)
//    }
//
//    var weekChange: Decimal {
//        guard
//            let open = weekPoints.first?.open,
//            let close = weekPoints.last?.close
//            else { return 0.0 }
//
//        return percentageChange(open: open, close: close)
//    }
//
//    var monthChange: Decimal {
//        guard
//            let open = monthPoints.first?.open,
//            let close = monthPoints.last?.close
//            else { return 0.0 }
//
//        return percentageChange(open: open, close: close)
//    }
//
//    var yearChange: Decimal {
//        guard
//            let open = yearPoints.first?.open,
//            let close = yearPoints.last?.close
//            else { return 0.0 }
//
//        return percentageChange(open: open, close: close)
//    }
    
//    var hourHigh: Decimal {
//        hourPoints.sorted(by: { $0.high > $1.high }).first?.high ?? 0.0
//    }
//
//    var hourLow: Decimal {
//        hourPoints.sorted(by: { $0.low < $1.low }).first?.low ?? 0.0
//    }
//
    var dayHigh: Decimal {
        dayOhlc.sorted(by: { $0.high > $1.high }).first?.high ?? 0.0
    }

    var dayLow: Decimal {
        dayOhlc.sorted(by: { $0.low < $1.low }).first?.low ?? 0.0
    }
//
//    var weekHigh: Decimal {
//        weekPoints.sorted(by: { $0.high > $1.high }).first?.high ?? 0.0
//    }
//
//    var weekLow: Decimal {
//        weekPoints.sorted(by: { $0.low < $1.low }).first?.low ?? 0.0
//    }
//
//    var monthHigh: Decimal {
//        monthPoints.sorted(by: { $0.high > $1.high }).first?.high ?? 0.0
//    }
//
//    var monthLow: Decimal {
//        monthPoints.sorted(by: { $0.low < $1.low }).first?.low ?? 0.0
//    }
//
//    var yearHigh: Decimal {
//        yearPoints.sorted(by: { $0.high > $1.high }).first?.high ?? 0.0
//    }
//
//    var yearLow: Decimal {
//        yearPoints.sorted(by: { $0.low < $1.low }).first?.low ?? 0.0
//    }
    
    private func percentageChange(open: Decimal, close: Decimal) -> Decimal {
        let decrease = close - open
        return (decrease/open) * 100
    }
}
