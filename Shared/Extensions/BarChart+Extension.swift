//
//  BarChart+Extension.swift
//  Portal
//
//  Created by Farid on 11/30/21.
//

import Foundation
import Charts
import SwiftUI
#if os(macOS)
import AppKit
#endif

extension Charts.BarChartView {
    func applyStandardSettings() {
        backgroundColor = .clear
        drawValueAboveBarEnabled = true
        pinchZoomEnabled = false
        drawBordersEnabled = false
        drawBarShadowEnabled = false
        drawGridBackgroundEnabled = false
        drawMarkers = true
        highlightFullBarEnabled = false
        legend.enabled = false
        legend.drawInside = false

        extraBottomOffset = 20
        animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
        
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.enabled = false
        leftAxis.drawZeroLineEnabled = false
        leftAxis.drawLabelsEnabled = true
        leftAxis.labelPosition = .insideChart
                
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.enabled = false
        
        xAxis.drawAxisLineEnabled = false
        xAxis.drawLabelsEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = false
        xAxis.granularity = 1
        xAxis.labelPosition = .bottom
        
        #if os(iOS)
        legend.font = UIFont(name: "Avenir-Medium", size: 12.0)!
        legend.textColor = UIColor(white: 1, alpha: 0.6)
        leftAxis.labelFont = UIFont(name: "Avenir-Medium", size: 12.0)!
        leftAxis.labelTextColor = UIColor(white: 1, alpha: 0.6)
        xAxis.labelFont = UIFont(name: "Avenir-Medium", size: 12.0)!
        xAxis.labelTextColor = UIColor(white: 1, alpha: 0.6)
        #elseif os(macOS)
        legend.font = NSFont(name: "Avenir-Medium", size: 12.0)!
        legend.textColor = NSColor(white: 1, alpha: 0.6)
        leftAxis.labelFont = NSFont(name: "Avenir-Medium", size: 12.0)!
        leftAxis.labelTextColor = NSColor(white: 1, alpha: 0.6)
        xAxis.labelFont = NSFont(name: "Avenir-Medium", size: 12.0)!
        xAxis.labelTextColor = NSColor(white: 1, alpha: 0.6)
        #endif
        
    }
}
