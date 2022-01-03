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
        ZStack {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    MarketValueView(
                        timeframe: $viewModel.selectedTimeframe,
                        currency: viewModel.state.wallet.currency,
                        totalValue: viewModel.totalValue,
                        change: viewModel.change,
                        high: viewModel.highest,
                        low: viewModel.lowest,
                        chartDataEntries: viewModel.chartDataEntries,
                        landscape: true,
                        type: .portfolio
                    )
                    .padding(.top, 12)
                    
                    HStack(spacing: 40) {
                        VStack(spacing: 10) {
                            Text("Best performing")
                                .font(Font.mainFont())
                                .foregroundColor(Color.white.opacity(0.5))
                            if let coin = viewModel.bestPerforming {
                                HStack {
                                    CoinImageView(size: 15, url: coin.icon)
                                    Text(coin.code)
                                        .font(Font.mainFont(size: 15))
                                        .foregroundColor(Color.white.opacity(0.8))
                                }
                            } else {
                                Text("-")
                                    .font(Font.mainFont(size: 15))
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                        }
                        
                        VStack(spacing: 10) {
                            Text("Worst performing")
                                .font(Font.mainFont())
                                .foregroundColor(Color.white.opacity(0.5))
                            if let coin = viewModel.worstPerforming {
                                HStack {
                                    CoinImageView(size: 15, url: coin.icon)
                                    Text(coin.code)
                                        .font(Font.mainFont(size: 15))
                                        .foregroundColor(Color.white.opacity(0.8))
                                }
                            } else {
                                Text("-")
                                    .font(Font.mainFont(size: 15))
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    Divider()
                        .background(Color.white.opacity(0.25))
                        .padding(.top, 31)
                        .padding(.bottom, 12)
                    
                    GeometryReader { geometry in
                        VStack {
                            Text("Asset allocation")
                                .font(Font.mainFont())
                                .foregroundColor(Color.white.opacity(0.6))
                                .padding(2)
                            
                            if geometry.size.height < 220 {
                                AssetAllocationView(assets: viewModel.assets, isBarChart: false)
                                    .frame(height: 150)
                            } else {
                                AssetAllocationView(assets: viewModel.assets, isBarChart: true)
                            }
                            
                        }
                    }
                }
                .frame(width: 256)
                .padding(.horizontal, 24)
                
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(Color.white.opacity(0.11))
                    
            }
            .blur(radius: viewModel.empty ? 6 : 0)

            if viewModel.empty {
                Text("Portfolio is empty")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.white)
            }
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalWalletBackground
            Color.black.opacity(0.58)
            PortfolioView(viewModel: PortfolioViewModel.config())
        }
        .frame(width: 304, height: 900)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
