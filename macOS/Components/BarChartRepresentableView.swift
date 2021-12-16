//
//  BarCHartUIKitView.swift
//  Portal (macOS)
//
//  Created by Farid on 26.08.2021.
//

import SwiftUI
import Charts

struct BarChartRepresentableView: NSViewRepresentable {
    let viewModel: IBarChartViewModel

    init(viewModel: AssetAllocationViewModel) {
        self.viewModel = viewModel
    }
    
    func makeNSView(context: Context) -> BarChartView {
        let barChart = BarChartView()
        barChart.applyStandardSettings()
        return barChart
    }

    func updateNSView(_ barChart: BarChartView, context: Context) {
        barChart.data = viewModel.assetAllocationBarChartData()
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: viewModel.barChartData().labels)
    }
}
