//
//  AssetAllocationView.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import SwiftUI

struct AssetAllocationView: View {
    private let viewModel: AssetAllocationViewModel
    private let isBarChart: Bool
    
    init(
        assets: [PortfolioItem],
        isBarChart: Bool = true
    ) {
        self.viewModel = AssetAllocationViewModel(assets: assets)
        self.isBarChart = isBarChart
    }
    
    var body: some View {
        if isBarChart {
            BarChartRepresentableView(viewModel: viewModel)
                .padding(.bottom, 10)
        } else {
            PieChartRepresentableView(viewModel: viewModel)
        }
    }
}

struct AssetAllocationView_Previews: PreviewProvider {
    static var previews: some View {
        AssetAllocationView(assets: [])
    }
}
