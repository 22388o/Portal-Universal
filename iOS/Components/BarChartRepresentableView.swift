//
//  BarChartRepresentableView.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import SwiftUI
import Charts

struct BarChartRepresentableView: UIViewRepresentable {
    let viewModel: IBarChartViewModel

    init(viewModel: AssetAllocationViewModel = AssetAllocationViewModel()) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> BarChartView {
        let barChart = BarChartView()
//        pieChart.applyStandardSettings()
        barChart.data = viewModel.assetAllocationBarChartData()
        barChart.backgroundColor = .clear
        barChart.drawValueAboveBarEnabled = true
        barChart.pinchZoomEnabled = false
        barChart.drawBordersEnabled = false
        barChart.drawBarShadowEnabled = false
        barChart.drawGridBackgroundEnabled = false
        barChart.drawMarkers = false
        barChart.leftAxis.drawAxisLineEnabled = false
        barChart.leftAxis.removeAllLimitLines()
        barChart.rightAxis.drawAxisLineEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.rightAxis.enabled = false
        barChart.rightAxis.removeAllLimitLines()
        
        let xaxis = barChart.xAxis
//                    xaxis.valueFormatter = axisFormatDelegate
                    xaxis.drawGridLinesEnabled = false
                    xaxis.labelPosition = .bottom
                    xaxis.centerAxisLabelsEnabled = false
//                    xaxis.valueFormatter = IndexAxisValueFormatter(values:self.months)
                    xaxis.granularity = 1

        barChart.leftAxis.enabled = false
        barChart.rightAxis.enabled = false
        barChart.drawBarShadowEnabled = false
        
        return barChart
    }

    func updateUIView(_ uiView: BarChartView, context: Context) {}
}
