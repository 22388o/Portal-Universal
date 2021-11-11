//
//  AssetViewLandscape.swift
//  Portal
//
//  Created by Farid on 10.04.2021.
//

import SwiftUI
import Charts
import Coinpaprika

struct AssetViewLandscape: View {
    @ObservedObject private var viewModel: AssetViewModel
    @ObservedObject private var state = Portal.shared.state
        
    init(viewModel: AssetViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.94))
            
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                
                HStack {
                    CoinImageView(size: 24, url: viewModel.coin.icon, placeholderForegroundColor: Color.assetValueLabel)
                    
                    Text("\(viewModel.coin.name)")
                        .font(.mainFont(size: 15))
                        .foregroundColor(Color.assetValueLabel)
                    Spacer()
                }
                
                HStack {
                    Text("\(viewModel.balance) \(viewModel.coin.code)")
                        .font(.mainFont(size: 28))
                        .padding(.bottom, 15)
                        .foregroundColor(Color.assetValueLabel)
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    HStack {
                        PButton(label: "Recieve", width: 124, height: 32, fontSize: 12, enabled: true) {
                            withAnimation(.easeIn(duration: 1.2)) {
                                state.receiveAsset.toggle()
                            }
                        }
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                        
                        PButton(label: "Send", width: 124, height: 32, fontSize: 12, enabled: viewModel.canSend) {
                            withAnimation(.easeIn(duration: 1.2)) {
                                state.sendAsset.toggle()
                            }
                        }
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                    }
                    PButton(label: "Send to exchange", width: 256, height: 32, fontSize: 12, enabled: false) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            
                        }
                    }
//                    .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                    
                    PButton(label: "Withdraw from exchange", width: 256, height: 32, fontSize: 12, enabled: false) {
                        withAnimation(.easeIn(duration: 0.2)) {
                            
                        }
                    }
//                    .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                }
                
                Spacer().frame(height: 10)
                
                AssetRouteSwitch(route: $viewModel.route)
                
                switch viewModel.route {
                case .value:
                    MarketValueView(
                        timeframe: $viewModel.selectedTimeframe,
                        valueCurrencyViewSate: $viewModel.valueCurrencySwitchState,
                        fiatCurrency: $state.fiatCurrency,
                        totalValue: viewModel.totalValue,
                        change: viewModel.change,
                        high: viewModel.dayHigh,
                        low: viewModel.dayLow,
                        chartDataEntries: viewModel.chartDataEntries,
                        landscape: true,
                        type: .asset
                    )
                case .transactions:
                    RecentTxsView(coin: state.selectedCoin)
                        .transition(.identity)
                case .alerts:
                    AlertsView(coin: viewModel.coin, createAlert: $state.createAlert)
                        .transition(.identity)
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(width: 304)
        .frame(minHeight: 650)
    }
}

struct AssetViewLandscape_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalWalletBackground
            Color.black.opacity(0.58)
            AssetViewLandscape(viewModel: AssetViewModel.config())
        }
        .frame(width: 304, height: 656)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
