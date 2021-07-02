//
//  AssetAllocationViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import SwiftUI

struct AssetAllocationViewModel: IPieChartModel, IBarChartViewModel {
    var assets: [IAsset]
    let isLineChart: Bool
    
    init(assets: [IAsset] = WalletMock().assets.map{ $0 }) {
        print("Asset allocation view model init")
        self.assets = assets
        self.isLineChart = UIScreen.main.bounds.height < 1024 ? false : true
    }
}
