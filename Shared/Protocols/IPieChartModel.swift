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

protocol IPieChartModel {
    var assets: [IAsset] { get }
}

extension IPieChartModel {
    var totalValueCurrency: Currency {
        .fiat(USD)
    }
    
    var totalPortfolioValue: Double {
        assets.map{ $0.balanceProvider.balance(currency: totalValueCurrency) }.reduce(0){ $0 + $1 }.rounded(toPlaces: 2)
    }
    
    func pieChartData() -> (entries: [PieChartDataEntry], colors: [UIColor]) {
        let minimumValue: Double = 5 //In %
        
        var assetAllocationValues = [Double]()
        var others = [Double]()
        var colors = [UIColor]()
        var labels = [String]()
        
        for asset in assets {
            let size = allocationSizeInPercents(for: asset)
            if size >= minimumValue {
                assetAllocationValues.append(size)
                labels.append(asset.coin.code + " \(size)%")
                colors.append(asset.coin.color)
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
        
        colors.append(.lightGray)
        
        return (entries, colors)
    }
    
    func allocationSizeInPercents(for asset: IAsset) -> Double {
        let value = asset.balanceProvider.balance(currency: totalValueCurrency)
        return ((value/totalPortfolioValue) * 100).rounded(toPlaces: 2)
    }
    
    func assetAllocationChartData() -> PieChartData {
        let pieData = pieChartData()
        let set = PieChartDataSet(values: pieData.entries, label: "Asset allocation")
        set.standardSettings(colors: pieData.colors)
        
        return PieChartData(dataSet: set)
    }
}
