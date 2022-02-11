//
//  PieChartRepresentableView.swift
//  Portal (macOS)
//
//  Created by Farid on 26.08.2021.
//

import SwiftUI
import Charts

struct PieChartRepresentableView: NSViewRepresentable {
    @Binding var assets: [PortfolioItem]
    private let viewModel: IPieChartModel

    init(assets: Binding<[PortfolioItem]>) {
        self._assets = assets
        self.viewModel = AssetAllocationViewModel(assets: assets.wrappedValue)
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
