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
//        minOffset = 0
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
        yaxis.labelPosition = .insideChart
        yaxis.drawAxisLineEnabled = false
        yaxis.drawLabelsEnabled = true
        yaxis.enabled = false
        
        let xaxis = getAxis(YAxis.AxisDependency.right)
        xaxis.labelPosition = .insideChart
        xaxis.drawLabelsEnabled = true
        xaxis.drawAxisLineEnabled = false
        xaxis.enabled = false
        
        autoScaleMinMaxEnabled = true
        setScaleEnabled(false)
        doubleTapToZoomEnabled = false
        highlightPerTapEnabled = true
        highlightPerDragEnabled = false
        
        let marker = LineChartMarkerView()
        marker.chartView = self
        self.marker = marker
    }
}
