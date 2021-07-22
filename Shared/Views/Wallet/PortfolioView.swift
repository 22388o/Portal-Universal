//
//  PortfolioView.swift
//  Portal
//
//  Created by Farid on 12.04.2021.
//

import SwiftUI

struct PortfolioView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                MarketValueView(
                    timeframe: $viewModel.selectedTimeframe,
                    valueCurrencyViewSate: $viewModel.valueCurrencySwitchState,
                    fiatCurrency: .constant(USD),
                    totalValue: viewModel.totalValue,
                    change: viewModel.change,
                    high: "$0.0",
                    low: "$0.0",
                    chartDataEntries: viewModel.chartDataEntries,
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
                    
                    AssetAllocationView(assets: viewModel.assets, showTotalValue: false)
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

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalWalletBackground
            Color.black.opacity(0.58)
            PortfolioView(viewModel: .init(assets: WalletMock().assets))
        }
        .frame(width: 304, height: 900)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
