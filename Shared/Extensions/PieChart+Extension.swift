//
//  PieChart+Extension.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Charts
import SwiftUI

extension Charts.PieChartView {
    func applyStandardSettings() {
        holeRadiusPercent = 0.85
        rotationAngle = 25
        holeColor = nil
        transparentCircleRadiusPercent = 0
        legend.enabled = false
        chartDescription.enabled = false
        noDataText = "No coins in the wallet"
        transparentCircleColor = UIColor.clear
        noDataTextColor = UIColor(white: 1, alpha: 0.4)
        noDataFont = UIFont(name: "Avenir-Medium", size: 12.0)!
        extraTopOffset = 10
        extraBottomOffset = 15
        extraLeftOffset = 10
        extraRightOffset = 10
    }
}

extension Charts.PieChartDataSet {
    func standardSettings(colors: [UIColor]) {
        selectionShift = 0
        sliceSpace = 7
        xValuePosition = .outsideSlice
        yValuePosition = .outsideSlice
        valueTextColor = UIColor(white: 1, alpha: 0.6)
        valueLineColor = UIColor(white: 1, alpha: 0.6)
        entryLabelFont = UIFont(name: "Avenir-Medium", size: 12.0)!
        valueLineWidth = 2.5
        valueLinePart1OffsetPercentage = 1.5
        valueLinePart1Length = 0.4
        valueLinePart2Length = 0.4
        drawValuesEnabled = false
        self.colors = colors
    }
}
