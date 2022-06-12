//
//  Array+Extension.swift
//  Portal
//
//  Created by Farid on 21.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Charts
import SwiftUI

extension Array where Element == UInt8 {
    func bytesToHexString() -> String {
        let format = "%02hhx" // "%02hhX" (uppercase)
        return self.map { String(format: format, $0) }.joined()
    }
}


extension Array where Element: ChartDataEntry {
    func dataSet(portfolio: Bool = true) -> LineChartDataSet {
        let ds = LineChartDataSet(values: self, label: String())
        #if os(iOS)
        ds.colors = [
            UIColor(red: 19.0/255.0, green: 143.0/255.0, blue: 199.0/255.0, alpha: 1),
            UIColor(red: 17.0/255.0, green: 255.0/255.0, blue: 142.0/255.0, alpha: 1)
        ]
        #elseif os(macOS)
        if portfolio {
            ds.colors = [
                NSColor(red: 19.0/255.0, green: 143.0/255.0, blue: 199.0/255.0, alpha: 1),
                NSColor(red: 17.0/255.0, green: 255.0/255.0, blue: 142.0/255.0, alpha: 1)
            ]
        } else {
            ds.colors = [
                NSColor(red: 255.0/255.0, green: 72.0/255.0, blue: 95.0/255.0, alpha: 1),
                NSColor(red: 255.0/255.0, green: 151.0/255.0, blue: 38.0/255.0, alpha: 1)
            ]
        }
        #endif
        
        ds.highlightEnabled = true
        ds.mode = .cubicBezier
        ds.drawHorizontalHighlightIndicatorEnabled = false
        ds.drawVerticalHighlightIndicatorEnabled = false
        
        ds.drawCirclesEnabled = false
        ds.lineWidth = 2.5
        
        #if os(iOS)
        let gradientColors = [
            UIColor(red: 0.0/255.0, green: 248.0/255.0, blue: 150.0/255.0, alpha: 0.6).cgColor,
            UIColor(red: 17.0/255.0, green: 83.0/255.0, blue: 79.0/255.0, alpha: 0.0).cgColor
            ] as CFArray
        #elseif os(macOS)
        let gradientColors: CFArray
        
        if portfolio {
            gradientColors = [
                NSColor(red: 0.0/255.0, green: 248.0/255.0, blue: 150.0/255.0, alpha: 0.6).cgColor,
                NSColor(red: 17.0/255.0, green: 83.0/255.0, blue: 79.0/255.0, alpha: 0.0).cgColor
            ] as CFArray
        } else {
            gradientColors = [
                NSColor(red: 243.0/255.0, green: 136.0/255.0, blue: 102.0/255.0, alpha: 0.67).cgColor,
                NSColor(white: 1, alpha: 0).cgColor
            ] as CFArray
        }
        #endif
        let colorLocations: [CGFloat] = [1.0, 0.0]
        
        let gradiendFillColor = CGGradient.init(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: gradientColors,
            locations: colorLocations
        )!
                
        ds.fill = Fill.fillWithLinearGradient(gradiendFillColor, angle: 90.0)
        ds.drawFilledEnabled = true
        ds.isDrawLineWithGradientEnabled = true
                        
        return ds
    }
}

#if os(macOS)
import AppKit
#endif


extension Array where Element == Color {
    #if os(iOS)
    func uiColors() -> [UIColor] {
        self.map{ UIColor($0) }
    }
    #elseif os(macOS)
    func nsColors() -> [NSColor] {
        self.map{ $0.nsColor }
    }
    #endif
}

extension Array where Element == ExchangeVolumeDataModel {
    func exchangeWithHighterTradingVolume(activeExchanges: [ExchangeModel]) -> ExchangeModel? {
        for exchange in self.sorted(by: {$0.qVol > $1.qVol}) {
            for portalExchange in activeExchanges {
                if exchange.id.lowercased() == portalExchange.id.lowercased() {
                    return portalExchange
                }
            }
        }
        return nil
    }
    func exchangeWithHighterQuoteBalance(activeExchanges: [ExchangeModel], quote: String) -> ExchangeModel? {
        var candidates = [ExchangeModel]()
        for exchange in self {
            for portalExchange in activeExchanges {
                if exchange.id.lowercased() == portalExchange.id.lowercased() {
                    candidates.append(portalExchange)
                }
            }
        }
        return candidates.first//sorted(by: {
          //  $0.balanceFor(symbol: quote)?.free ?? 0.0 > $1.balanceFor(symbol: quote)?.free ?? 0.0
        //}).first
    }
}

