//
//  AssetAllocationView.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import SwiftUI

struct AssetAllocationView: View {
    let viewModel: AssetAllocationViewModel
    let showTotalValue: Bool
    
    init(
        assets: [IAsset],
        showTotalValue: Bool = true
    ) {
        print("Asset allocation view init")
        self.viewModel = AssetAllocationViewModel(assets: assets)
        self.showTotalValue = showTotalValue
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLineChart {
                BarChartUIKitView(viewModel: viewModel)
                    .frame(height: 350)
                    .offset(y: 100)
                    
            } else {
                PieChartUIKitView(viewModel: viewModel)
            }
        }
    }
}

struct AssetAllocationView_Previews: PreviewProvider {
    static var previews: some View {
        AssetAllocationView(assets: [])
    }
}
