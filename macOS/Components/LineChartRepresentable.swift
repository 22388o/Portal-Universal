//
//  LineChartRepresentable.swift
//  Portal (macOS)
//
//  Created by Farid on 26.08.2021.
//

import SwftUI
import Charts

struct LineChartRepresentable: NSViewRepresentable {
    let chartDataEntries: [ChartDataEntry]
    
    func makeNSView(context: Context) -> LineChartView {
        let lineChart = LineChartView()
        lineChart.applyStandardSettings()
                
        updateChartData(lineChart: lineChart)
        
        return lineChart
    }

    func updateNSView(_ lineChart: LineChartView, context: Context) {
        updateChartData(lineChart: lineChart)
    }
    
    func updateChartData(lineChart: LineChartView) {
        let data = LineChartData()
        let dataSet = chartDataEntries.dataSet()
        
        data.dataSets = [dataSet]
                
        let maxValue = chartDataEntries.map{$0.y}.max()
        
        if maxValue != nil {
//            dataSet.gradientPositions = [0, CGFloat(maxValue!)]
            lineChart.data = data
            lineChart.notifyDataSetChanged()
        }
    }
}
