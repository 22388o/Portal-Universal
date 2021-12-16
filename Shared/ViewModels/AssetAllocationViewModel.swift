//
//  AssetAllocationViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import SwiftUI

struct AssetAllocationViewModel: IPieChartModel, IBarChartViewModel {
    let assets: [PortfolioItem]
    let isLineChart: Bool
    
    init(assets: [PortfolioItem]) {
        self.assets = assets
        self.isLineChart = false
    }
}
