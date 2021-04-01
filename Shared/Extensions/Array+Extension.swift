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

extension Array where Element: ChartDataEntry {
    func dataSet() -> LineChartDataSet {
        let ds = LineChartDataSet(entries: self, label: String())
        
        ds.colors = [
            UIColor(red: 19.0/255.0, green: 143.0/255.0, blue: 199.0/255.0, alpha: 1),
            UIColor(red: 17.0/255.0, green: 255.0/255.0, blue: 142.0/255.0, alpha: 1)
        ]
        
        ds.highlightEnabled = false
        ds.mode = .cubicBezier
        ds.drawHorizontalHighlightIndicatorEnabled = false
        
        ds.drawCirclesEnabled = false
        ds.lineWidth = 2.5
        
        let gradientColors = [
            UIColor(red: 0.0/255.0, green: 248.0/255.0, blue: 150.0/255.0, alpha: 0.6).cgColor,
            UIColor(red: 17.0/255.0, green: 83.0/255.0, blue: 79.0/255.0, alpha: 0.0).cgColor
            ] as CFArray
        
        let colorLocations: [CGFloat] = [1.0, 0.0]
        
        let gradiendFillColor = CGGradient.init(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: gradientColors,
            locations: colorLocations
        )!
                
        ds.fill = LinearGradientFill(gradient: gradiendFillColor, angle: 90.0)
        ds.drawFilledEnabled = true
        
        ds.isDrawLineWithGradientEnabled = true
                
        return ds
    }
}
