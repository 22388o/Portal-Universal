//
//  AssetView.swift
//  Portal
//
//  Created by Farid on 10.04.2021.
//

import SwiftUI
import Charts

struct AssetView: View {
    @Binding var showReceiveView: Bool
    @ObservedObject private var viewModel: AssetViewModel
    
    init(viewModel: WalletScene.ViewModel) {
        self.viewModel = AssetViewModel(asset: viewModel.selectedAsset)
        self._showReceiveView = Binding(
            get: { viewModel.showReceiveView },
            set: { viewModel.showReceiveView = $0 }
        )
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.94))
            
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                
                HStack {
                    Image(uiImage: viewModel.asset.coin.icon)
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
                            withAnimation {
                                showReceiveView.toggle()
                            }
                        }
                        PButton(label: "Send", width: 124, height: 32, fontSize: 12, enabled: false) {
                            
                        }
                    }
                    PButton(label: "Send to exchange", width: 256, height: 32, fontSize: 12, enabled: false) {
                        
                    }
                    PButton(label: "Withdraw from exchange", width: 256, height: 32, fontSize: 12, enabled: false) {
                        
                    }
                }
                
                Spacer().frame(height: 10)
                
                AssetRouteSwitch(route: $viewModel.route)
                
                switch viewModel.route {
                case .value:
                    MarketValueView(
                        timeframe: $viewModel.selectedTimeframe,
                        totalValue: $viewModel.totalValue,
                        change: $viewModel.change,
                        chartDataEntries: $viewModel.chartDataEntries,
                        valueCurrencyViewSate: $viewModel.valueCurrencySwitchState,
                        type: .asset
                    )
//                    .transition(.move(edge: .bottom))
                case .transactions:
                    VStack {
                        Spacer()
                        Text("Transactions")
                        Spacer()
                    }
                    .padding()
//                    .transition(.move(edge: .bottom))
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
