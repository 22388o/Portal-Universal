//
//  AssetView.swift
//  Portal
//
//  Created by Farid on 10.04.2021.
//

import SwiftUI
import Charts
import Coinpaprika

struct AssetView: View {
    @State private var route: AssetViewRoute = .value
    
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
                    viewModel.coin.icon
                        .resizable()
                        .frame(width: 24, height: 24)
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
                
                VStack {
                    HStack {
                        PButton(label: "Recieve", width: 124, height: 32, fontSize: 12, enabled: true) {
                            withAnimation {
                                state.receiveAsset.toggle()
                            }
                        }
                        PButton(label: "Send", width: 124, height: 32, fontSize: 12, enabled: true) {
                            withAnimation {
                                state.sendAsset.toggle()
                            }
                        }
                    }
                    PButton(label: "Send to exchange", width: 256, height: 32, fontSize: 12, enabled: false) {
                        withAnimation(.easeIn(duration: 0.2)) {
                            
                        }
                    }
                    PButton(label: "Withdraw from exchange", width: 256, height: 32, fontSize: 12, enabled: false) {
                        withAnimation(.easeIn(duration: 0.2)) {
                            
                        }
                    }
                }
                
                Spacer().frame(height: 10)
                
                AssetRouteSwitch(route: $route)
                
                switch route {
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
    }
}

struct AssetView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalWalletBackground
            Color.black.opacity(0.58)
            AssetView(viewModel: AssetViewModel.config())
        }
        .frame(width: 304, height: 656)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
