//
//  IPieChartModel.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI
import Charts

protocol IBarChartViewModel {
    var assets: [IAsset] { get }
    var colors: [Color] { get }
}

extension IBarChartViewModel {
    var colors: [Color] {
        []//assets.map{ $0.coin.color }
    }
    var totalValueCurrency: Currency {
        .fiat(USD)
    }
    
    var totalPortfolioValue: Double {
        0//assets.map{ $0.balanceProvider.balance(currency: totalValueCurrency).double }.reduce(0){ $0 + $1 }.rounded(toPlaces: 2)
    }
    
    func barChartData() -> (entries: [BarChartDataEntry], colors: [Color]) {
        let minimumValue: Double = 5 //In %
        
        var assetAllocationValues = [Double]()
        var others = [Double]()
        var colors = [Color]()
        var labels = [String]()
        var icons = [Image]()
        
        for asset in assets {
            let size = allocationSizeInPercents(for: asset)
            if size >= minimumValue {
                assetAllocationValues.append(size)
                labels.append(asset.coin.code + " \(size)%")
//                colors.append(asset.coin.color)
//                icons.append(asset.coin.icon)
            } else {
                others.append(size)
            }
        }
        
        //Add main assets
        
        var entries = [BarChartDataEntry]()
        for (index, value) in assetAllocationValues.enumerated() {
            let entry = BarChartDataEntry(x: Double(index), y: value)
            entries.append(entry)
        }
        
//        //Add others
//
//        let othersSize = others.reduce(0, {$0 + $1}).rounded(toPlaces: 4)
////        let othersLabel = "Others \(othersSize)%"
//        let entry = BarChartDataEntry(x: Double(entries.count + 1), y: othersSize)
//        entries.append(entry)
//
////        colors.append(.gray)
        
        return (entries, colors)
    }
    
    func allocationSizeInPercents(for asset: IAsset) -> Double {
        return 0
//        let value = asset.balanceProvider.balance(currency: totalValueCurrency).double
//        return ((value/totalPortfolioValue) * 100).rounded(toPlaces: 2)
    }
    
    func assetAllocationBarChartData() -> BarChartData {
        let barData = barChartData()
        let set = BarChartDataSet(values: barData.entries, label: String())
        #if os(iOS)
        set.colors = barData.colors.map {UIColor($0)}
        #else
        set.colors = barData.colors.map {$0.nsColor}
        #endif
        return BarChartData(dataSet: set)
    }
}
#if os(macOS)
extension Color {
    var nsColor: NSColor {
        if #available(OSX 11.0, *) {
            return NSColor(self)
        }

        let scanner = Scanner(string: description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000FF) / 255
        }
        return NSColor(red: r, green: g, blue: b, alpha: a)
    }
}
#endif

protocol IPieChartModel {
    var assets: [IAsset] { get }
}

extension IPieChartModel {
    var totalValueCurrency: Currency {
        .fiat(USD)
    }
    
    var totalPortfolioValue: Double {
        return 0
//        assets.map{ $0.balanceProvider.balance(currency: totalValueCurrency).double }.reduce(0){ $0 + $1 }.rounded(toPlaces: 2)
    }
    
    func pieChartData() -> (entries: [PieChartDataEntry], colors: [Color]) {
        let minimumValue: Double = 5 //In %
        
        var assetAllocationValues = [Double]()
        var others = [Double]()
        var colors = [Color]()
        var labels = [String]()
        
        for asset in assets {
            let size = allocationSizeInPercents(for: asset)
            if size >= minimumValue {
                assetAllocationValues.append(size)
                labels.append(asset.coin.code + " \(size)%")
//                colors.append(asset.coin.color)
            } else {
                others.append(size)
            }
        }
        
        //Add main assets
        
        var entries = [PieChartDataEntry]()
        for (index, value) in assetAllocationValues.enumerated() {
            let entry = PieChartDataEntry(value: value, label: labels[index])
            entries.append(entry)
        }
        
        //Add others
        
        let othersSize = others.reduce(0, {$0 + $1}).rounded(toPlaces: 4)
        let othersLabel = "Others \(othersSize)%"
        let entry = PieChartDataEntry(value: othersSize, label: othersLabel)
        entries.append(entry)
        
        colors.append(.gray)
        
        return (entries, colors)
    }
    
    func allocationSizeInPercents(for asset: IAsset) -> Double {
        return 0
//        let value = asset.balanceProvider.balance(currency: totalValueCurrency).double
//        return ((value/totalPortfolioValue) * 100).rounded(toPlaces: 2)
    }
    
    func assetAllocationChartData() -> PieChartData {
        let pieData = pieChartData()
        let set = PieChartDataSet(values: pieData.entries, label: "Asset allocation")
        set.standardSettings(colors: pieData.colors)
        
        return PieChartData(dataSet: set)
    }
}
