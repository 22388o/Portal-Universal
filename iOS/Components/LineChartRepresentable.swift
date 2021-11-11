//
//  LineChartRepresentable.swift
//  Portal (iOS)
//
//  Created by Farid on 26.08.2021.
//

import SwiftUI
import Charts

struct LineChartRepresentable: UIViewRepresentable {
    let chartDataEntries: [ChartDataEntry]
        
    func makeUIView(context: Context) -> LineChartView {
        let lineChart = LineChartView()
        lineChart.applyStandardSettings()
                
        updateChartData(lineChart: lineChart)
        
        let marker = LineChartMarkerView()
        marker.chartView = lineChart
        lineChart.marker = marker
        
        return lineChart
    }

    func updateUIView(_ lineChart: LineChartView, context: Context) {
        updateChartData(lineChart: lineChart)
    }
    
    func updateChartData(lineChart: LineChartView) {
        let data = LineChartData()
        let dataSet = chartDataEntries.dataSet()
        
        data.dataSets = [dataSet]
                
        let maxValue = chartDataEntries.map{$0.y}.max()
        
        if maxValue != nil {
            dataSet.gradientPositions = [0, CGFloat(maxValue!)]
            lineChart.data = data
            lineChart.notifyDataSetChanged()
        }
    }
}
