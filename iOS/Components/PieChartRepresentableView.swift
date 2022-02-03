//
//  PieChartRepresentableView.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Charts
import SwiftUI

struct PieChartRepresentableView: UIViewRepresentable {
    @Binding var assets: [PortfolioItem]
    private let viewModel: IPieChartModel

    init(assets: Binding<[PortfolioItem]>) {
        self._assets = assets
        self.viewModel = AssetAllocationViewModel(assets: assets.wrappedValue)
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
