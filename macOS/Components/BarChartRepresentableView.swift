//
//  BarCHartUIKitView.swift
//  Portal (macOS)
//
//  Created by Farid on 26.08.2021.
//

import SwiftUI
import Charts

struct BarChartRepresentableView: NSViewRepresentable {
    @Binding var assets: [PortfolioItem]
    private let viewModel: IBarChartViewModel

    init(assets: Binding<[PortfolioItem]>) {
        self._assets = assets
        self.viewModel = AssetAllocationViewModel(assets: assets.wrappedValue)
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
