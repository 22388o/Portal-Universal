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

    init(viewModel: AssetAllocationViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> BarChartView {
        let barChart = BarChartView()
        barChart.applyStandardSettings()
        return barChart
    }

    func updateUIView(_ barChart: BarChartView, context: Context) {
        barChart.data = viewModel.assetAllocationBarChartData()
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: viewModel.barChartData().labels)
    }
}
