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
    
    var hourPoints = [MarketSnapshot]()
    var dayPoints = [MarketSnapshot]()
    var weekPoints = [MarketSnapshot]()
    var monthPoints = [MarketSnapshot]()
    var yearPoints = [MarketSnapshot]()
    
    var hasData: Bool = true
    
    func price(currency: Currency) -> Double {
        return priceData?.price ?? 0.0
    }
    
    func priceString(currency: Currency) -> String {
        switch currency {
        case .btc:
            return priceData?.price.btcFormatted() ?? 0.0.btcFormatted()
        case .eth:
            return priceData?.price.ethFormatted() ?? 0.0.ethFormatted()
        case .fiat(let currency):
            let value = (priceData?.price ?? 0.0) * currency.rate
            return StringFormatter.localizedValueString(value: value, symbol: currency.symbol)
        }
    }
    
    func changeInPercents(tf: Timeframe) -> Double {
        switch tf {
        case .hour:
            return hourChange
        case .day:
            return dayChange
        case .week:
            return weekChange
        case .month:
            return monthChange
        case .year:
            return yearChange
        case .allTime:
            return 0.0
        }
    }
    
    func changeString(for timeframe: Timeframe, currrency: Currency) -> String {
        let price = self.price(currency: currrency)
        let change = self.changeInPercents(tf: timeframe) 

        return StringFormatter.changeString(price: price, change: change, currency: currrency)
    }
    
    var hourChange: Double {
        guard
            let open = hourPoints.first?.open,
            let close = hourPoints.last?.close
            else { return 0.0 }
        
        return percentageChange(open: open, close: close)
    }
    
    var dayChange: Double {
        guard
            let open = dayPoints.first?.open,
            let close = dayPoints.last?.close
            else { return 0.0 }
        
        return percentageChange(open: open, close: close)
    }
    
    var weekChange: Double {
        guard
            let open = weekPoints.first?.open,
            let close = weekPoints.last?.close
            else { return 0.0 }
        
        return percentageChange(open: open, close: close)
    }
    
    var monthChange: Double {
        guard
            let open = monthPoints.first?.open,
            let close = monthPoints.last?.close
            else { return 0.0 }
        
        return percentageChange(open: open, close: close)
    }
    
    var yearChange: Double {
        guard
            let open = yearPoints.first?.open,
            let close = yearPoints.last?.close
            else { return 0.0 }
        
        return percentageChange(open: open, close: close)
    }
    
    var hourHigh: Double {
        hourPoints.sorted(by: { $0.high > $1.high }).first?.high ?? 0.0
    }
    
    var hourLow: Double {
        hourPoints.sorted(by: { $0.low < $1.low }).first?.low ?? 0.0
    }
    
    var dayHigh: Double {
        dayPoints.sorted(by: { $0.high > $1.high }).first?.high ?? 0.0
    }
    
    var dayLow: Double {
        dayPoints.sorted(by: { $0.low < $1.low }).first?.low ?? 0.0
    }
    
    var weekHigh: Double {
        weekPoints.sorted(by: { $0.high > $1.high }).first?.high ?? 0.0
    }
    
    var weekLow: Double {
        weekPoints.sorted(by: { $0.low < $1.low }).first?.low ?? 0.0
    }
    
    var monthHigh: Double {
        monthPoints.sorted(by: { $0.high > $1.high }).first?.high ?? 0.0
    }
    
    var monthLow: Double {
        monthPoints.sorted(by: { $0.low < $1.low }).first?.low ?? 0.0
    }
    
    var yearHigh: Double {
        yearPoints.sorted(by: { $0.high > $1.high }).first?.high ?? 0.0
    }
    
    var yearLow: Double {
        yearPoints.sorted(by: { $0.low < $1.low }).first?.low ?? 0.0
    }
    
    private func percentageChange(open: Double, close: Double) -> Double {
        let decrease = close - open
        return (decrease/open) * 100
    }
}
