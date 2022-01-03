//
//  PieChartRepresentableView.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Charts
import SwiftUI

struct PieChartRepresentableView: UIViewRepresentable {
    let viewModel: IPieChartModel

    init(viewModel: AssetAllocationViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> PieChartView {
        let pieChart = PieChartView()
        pieChart.applyStandardSettings()
        return pieChart
    }

    func updateUIView(_ pieChart: PieChartView, context: Context) {
        pieChart.data = viewModel.assetAllocationChartData()
    }
}
