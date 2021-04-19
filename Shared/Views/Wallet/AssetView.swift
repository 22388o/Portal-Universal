//
//  AssetView.swift
//  Portal
//
//  Created by Farid on 10.04.2021.
//

import SwiftUI
import Charts

struct AssetView: View {
    
    enum Route {
        case value, transactions, alerts
    }
    
    @Binding var receiveAsset: Bool
    @Binding var sendAsset: Bool
    @Binding var sendAssetToExchange: Bool
    @Binding var withdrawAssetFromExchange: Bool
    @Binding var allTxs: Bool
    @Binding var route: Route
    
    @ObservedObject private var viewModel: AssetViewModel
    
    init(viewModel: WalletScene.ViewModel) {
        self.viewModel = AssetViewModel(asset: viewModel.selectedAsset)
        
        self._receiveAsset = Binding(
            get: { viewModel.receiveAsset },
            set: { viewModel.receiveAsset = $0 }
        )
        self._sendAsset = Binding(
            get: { viewModel.sendAsset },
            set: { viewModel.sendAsset = $0 }
        )
        self._sendAssetToExchange = Binding(
            get: { viewModel.sendAssetToExchange },
            set: { viewModel.sendAssetToExchange = $0 }
        )
        self._withdrawAssetFromExchange = Binding(
            get: { viewModel.withdrawAssetFromExchange },
            set: { viewModel.withdrawAssetFromExchange = $0 }
        )
        self._route = Binding(
            get: { viewModel.assetViewRoute },
            set: { viewModel.assetViewRoute = $0 }
        )
        self._allTxs = Binding(
            get: { viewModel.allTransactions },
            set: { viewModel.allTransactions = $0 }
        )
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.94))
            
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                
                HStack {
                    viewModel.asset.coin.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("\(viewModel.asset.coin.code)")
                        .font(.mainFont(size: 15))
                    Spacer()
                }
                
                HStack {
                    Text("\(viewModel.balance) \(viewModel.asset.coin.code)")
                        .font(.mainFont(size: 28))
                        .padding(.bottom, 15)
                    Spacer()
                }
                
                VStack {
                    HStack {
                        PButton(label: "Recieve", width: 124, height: 32, fontSize: 12, enabled: true) {
                            withAnimation(.easeIn(duration: 0.2)) {
                                receiveAsset.toggle()
                            }
                        }
                        PButton(label: "Send", width: 124, height: 32, fontSize: 12, enabled: true) {
                            withAnimation(.easeIn(duration: 0.2)) {
                                sendAsset.toggle()
                            }
                        }
                    }
                    PButton(label: "Send to exchange", width: 256, height: 32, fontSize: 12, enabled: true) {
                        withAnimation(.easeIn(duration: 0.2)) {
                            sendAssetToExchange.toggle()
                        }
                    }
                    PButton(label: "Withdraw from exchange", width: 256, height: 32, fontSize: 12, enabled: true) {
                        withAnimation(.easeIn(duration: 0.2)) {
                            withdrawAssetFromExchange.toggle()
                        }
                    }
                }
                
                Spacer().frame(height: 10)
                
                AssetRouteSwitch(route: $route)
                
                switch route {
                case .value:
                    MarketValueView(
                        timeframe: $viewModel.selectedTimeframe,
                        totalValue: $viewModel.totalValue,
                        change: $viewModel.change,
                        chartDataEntries: $viewModel.chartDataEntries,
                        valueCurrencyViewSate: $viewModel.valueCurrencySwitchState,
                        type: .asset
                    )
                    .transition(.identity)
                case .transactions:
                    RecentTxsView(coin: viewModel.asset.coin, showAllTxs: $allTxs)
                        .transition(.identity)
                case .alerts:
                    VStack {
                        Spacer()
                        Text("Alerts")
                        Spacer()
                    }
                    .padding()
//                    .transition(.move(edge: .bottom))
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
            Color.portalGradientBackground
            Color.black.opacity(0.58)
            AssetView(viewModel: .init(name: "Personal", assets: WalletMock().assets))
        }
        .frame(width: 304, height: 656)
        .previewLayout(PreviewLayout.sizeThatFits)
//        .padding()
    }
}
