//
//  BarChartXAxixValueFormatter.swift
//  Portal
//
//  Created by Farid on 11/30/21.
//

import Charts

class BarChartXAxixValueFormatter: NSObject, ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let formattedString = String(format: "%.2f", value)
        return "\(formattedString)%"
    }
}


