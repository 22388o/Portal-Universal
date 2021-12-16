//
//  PieChartRepresentableView.swift
//  Portal (macOS)
//
//  Created by Farid on 26.08.2021.
//

import SwiftUI
import Charts

struct PieChartRepresentableView: NSViewRepresentable {
    let viewModel: IPieChartModel

    init(viewModel: AssetAllocationViewModel) {
        self.viewModel = viewModel
    }
    
    func makeNSView(context: Context) -> PieChartView {
        let pieChart = PieChartView()
        pieChart.applyStandardSettings()
        return pieChart
    }

    func updateNSView(_ pieChart: PieChartView, context: Context) {
        pieChart.data = viewModel.assetAllocationChartData()
    }
}
