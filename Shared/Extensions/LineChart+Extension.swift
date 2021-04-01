//
//  LineChart+Extension.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Charts

extension LineChartView {
    func applyStandardSettings() {
        minOffset = 0
        maxVisibleCount = 0
        dragEnabled = false
        chartDescription.enabled = false
        legend.enabled = false
        
        leftAxis.drawGridLinesEnabled = false
        rightAxis.drawGridLinesEnabled = false
        xAxis.drawGridLinesEnabled = false
        drawGridBackgroundEnabled = false
        
        xAxis.drawLabelsEnabled = false
        xAxis.drawAxisLineEnabled = false
        
        let yaxis = getAxis(YAxis.AxisDependency.left)
        yaxis.drawLabelsEnabled = false
        yaxis.enabled = false
        
        let xaxis = getAxis(YAxis.AxisDependency.right)
        xaxis.drawLabelsEnabled = false
        xaxis.enabled = false
    }
}
