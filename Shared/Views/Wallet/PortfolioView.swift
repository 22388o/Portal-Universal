//
//  PortfolioView.swift
//  Portal
//
//  Created by Farid on 12.04.2021.
//

import SwiftUI

struct PortfolioView: View {
    @StateObject var viewModel: PortfolioViewModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                MarketValueView(
                    timeframe: $viewModel.selectedTimeframe,
                    totalValue: $viewModel.totalValue,
                    change: $viewModel.change,
                    chartDataEntries: $viewModel.chartDataEntries,
                    valueCurrencyViewSate: $viewModel.valueCurrencySwitchState,
                    type: .portfolio
                )
                .padding(.top, 12)
                
                HStack(spacing: 15) {
                    VStack(spacing: 10) {
                        Text("Best performing")
                            .font(Font.mainFont())
                            .foregroundColor(Color.white.opacity(0.5))
                        Text("BTC")
                            .font(Font.mainFont(size: 15))
                            .foregroundColor(Color.white.opacity(0.8))

                    }
                    
                    VStack(spacing: 10) {
                        Text("Worst performing")
                            .font(Font.mainFont())
                            .foregroundColor(Color.white.opacity(0.5))
                        Text("ETH")
                            .font(Font.mainFont(size: 15))
                            .foregroundColor(Color.white.opacity(0.8))

                    }
                }
                .padding(.top, 20)
                
                Divider()
                    .background(Color.white.opacity(0.25))
                    .padding(.vertical, 31)
                
                VStack {
                    Text("Asset allocation")
                        .font(Font.mainFont())
                        .foregroundColor(Color.white.opacity(0.6))
                        .padding(2)
                    
                    AssetAllocationView(assets: self.viewModel.assets, showTotalValue: false)
                        .frame(height: 150)
                }
            }
            .frame(width: 256)
            .padding(.horizontal, 24)
            
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color.white.opacity(0.11))
                
        }
    }		
}

struct AssetAllocationViewModel: IPieChartModel {
    var assets: [IAsset]
    
    init(assets: [IAsset] = WalletMock().assets.map{ $0 }) {
        print("Asset allocation view model init")
        self.assets = assets
    }
}

import Charts

struct PieChartUIKitWrapper: UIViewRepresentable {
    let viewModel: IPieChartModel

    init(viewModel: AssetAllocationViewModel = AssetAllocationViewModel()) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> PieChartView {
        let pieChart = PieChartView()
        pieChart.applyStandardSettings()
        pieChart.data = viewModel.assetAllocationChartData()
        return pieChart
    }

    func updateUIView(_ uiView: PieChartView, context: Context) {}
}

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
            if showTotalValue {
                Text("$" + "\(viewModel.totalPortfolioValue)")
                    .font(Font.mainFont(size: 16))
                    .foregroundColor(Color.white)
            }
            PieChartUIKitWrapper(viewModel: viewModel)
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalGradientBackground
            Color.black.opacity(0.58)
            PortfolioView(viewModel: .init(assets: WalletMock().assets))
        }
        .frame(width: 304, height: 700)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
