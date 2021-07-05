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
    @Namespace private var animation
    
    @State private var route: AssetViewRoute = .value
    
    @Binding var receiveAsset: Bool
    @Binding var sendAsset: Bool
    @Binding var allTxs: Bool
    @Binding var createAlert: Bool
    
    @ObservedObject private var viewModel: AssetViewModel
    
    let fiatCurrency: FiatCurrency
    
    init(sceneViewModel: WalletSceneViewModel, fiatCurrency: FiatCurrency) {
        self.fiatCurrency = fiatCurrency
        self.viewModel = AssetViewModel(asset: sceneViewModel.selectedAsset, fiatCurrency: fiatCurrency)
        
        self._receiveAsset = Binding(
            get: { sceneViewModel.receiveAsset },
            set: { sceneViewModel.receiveAsset = $0 }
        )
        self._sendAsset = Binding(
            get: { sceneViewModel.sendAsset },
            set: { sceneViewModel.sendAsset = $0 }
        )
        self._allTxs = Binding(
            get: { sceneViewModel.allTransactions },
            set: { sceneViewModel.allTransactions = $0 }
        )
        self._createAlert = Binding(
            get: { sceneViewModel.createAlert },
            set: { sceneViewModel.createAlert = $0 }
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
                    Text("\(viewModel.asset.coin.name)")
                        .font(.mainFont(size: 15))
                        .foregroundColor(Color.assetValueLabel)
                    Spacer()
                }
                
                HStack {
                    Text("\(viewModel.balance) \(viewModel.asset.coin.code)")
                        .font(.mainFont(size: 28))
                        .padding(.bottom, 15)
                        .foregroundColor(Color.assetValueLabel)
                    Spacer()
                }
                
                VStack {
                    HStack {
                        PButton(label: "Recieve", width: 124, height: 32, fontSize: 12, enabled: true) {
                            withAnimation {
                                receiveAsset.toggle()
                            }
                        }
                        PButton(label: "Send", width: 124, height: 32, fontSize: 12, enabled: true) {
                            withAnimation {
                                sendAsset.toggle()
                            }
                        }
                        .matchedGeometryEffect(id: "Shape", in: animation)
                    }
                    PButton(label: "Swap", width: 256, height: 32, fontSize: 12, enabled: false) {
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
                        fiatCurrency: fiatCurrency,
                        totalValue: viewModel.totalValue,
                        change: viewModel.change,
                        high: viewModel.dayHigh,
                        low: viewModel.dayLow,
                        chartDataEntries: viewModel.chartDataEntries,
                        type: .asset
                    )
                case .transactions:
                    RecentTxsView(asset: viewModel.asset, showAllTxs: $allTxs)
                        .transition(.identity)
                case .alerts:
                    AlertsView(coin: viewModel.asset.coin, createAlert: $createAlert)
                        .transition(.identity)
                }
            }
            .padding(.horizontal, 24)
            .zIndex(0)
        }
        .frame(width: 304)
    }
}

struct AssetView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalWalletBackground
            Color.black.opacity(0.58)
            AssetView(
                sceneViewModel: .init(wallet: WalletMock(), fiatCurrency: USD),
                fiatCurrency: USD
            )
        }
        .frame(width: 304, height: 656)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
