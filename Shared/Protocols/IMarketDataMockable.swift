//
//  IMarketDataMockable.swift
//  Portal
//
//  Created by Farid on 21.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

protocol IMarketDataMockable {
    func mockedMarketData() -> [String : CoinMarketData]
}

extension IMarketDataMockable {
    func mockedMarketData() -> [String : CoinMarketData] {
        let assetsSymbols = "BTC,BCH,ETH,XLM,XTZ"
        var marketData = [String : CoinMarketData]()
        if let responseData = hourDataResponse.data(using: .utf8) {
            do {
                let unfilteredData = try JSONDecoder().decode([String:[MarketSnapshot]].self, from: responseData)
                let filteredData = filteredDict(unfilteredData)
                var hasData: Bool = false
                for hourPoints in filteredData {
                    if marketData[hourPoints.key] == nil {
                        marketData[hourPoints.key] = CoinMarketData()
                    }
                    marketData[hourPoints.key]?.hourPoints = hourPoints.value
                    hasData = true
                }
                marketData[assetsSymbols]?.hasData = hasData
            } catch {
                print("\(#function) error: \(error)")
                return [:]
            }
        }
        return marketData
    }
    
    func filteredDict(_ initialDictionary: [String:[MarketSnapshot]]) -> [String:[MarketSnapshot]] {
        //filtered out empty values from cryptomarket
        var filteredDictionary: [String:[MarketSnapshot]] = [:]
        for dictionary in initialDictionary {
            filteredDictionary[dictionary.key] = dictionary.value.filter{$0.open > 0 && $0.close > 0}
        }
        return filteredDictionary
    }
}
