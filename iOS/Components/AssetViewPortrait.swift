//
//  AssetViewPortrait.swift
//  Portal (iOS)
//
//  Created by Farid on 08.11.2021.
//

import SwiftUI
import Charts
import Coinpaprika

struct AssetViewPortrait: View {
    @StateObject private var txsViewModel: TxsViewModel
    @ObservedObject private var viewModel: AssetViewModel
    @ObservedObject private var state = Portal.shared.state
        
    init(viewModel: AssetViewModel) {
        self.viewModel = viewModel
        
        guard let vm = TxsViewModel.config(coin: viewModel.coin) else {
            fatalError("\(#function) Cannot config TxsViewModel")
        }
        
        self._txsViewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.94))
            
            VStack(spacing: 0) {
                Spacer().frame(height: 14)
                
                HStack {
                    CoinImageView(size: 24, url: viewModel.coin.icon, placeholderForegroundColor: Color.assetValueLabel)
                    
                    Text("\(viewModel.coin.name)")
                        .font(.mainFont(size: 15))
                        .foregroundColor(Color.assetValueLabel)
                    Spacer()
                    Text("\(viewModel.balance) \(viewModel.coin.code)")
                        .font(.mainFont(size: 28))
                        .foregroundColor(Color.assetValueLabel)
                }
                
                Spacer().frame(height: 14)
                
                GeometryReader { geometry in
                    VStack(spacing: 8) {
                        HStack {
                            PButton(label: "Receive", width: geometry.size.width/2, height: 32, fontSize: 12, enabled: true) {
                                withAnimation(.easeIn(duration: 3.0)) {
                                    state.modalView = .receiveAsset
                                }
                            }
                            .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                            
                            PButton(label: "Send", width: geometry.size.width/2, height: 32, fontSize: 12, enabled: viewModel.canSend) {
                                withAnimation(.easeIn(duration: 3.0)) {
                                    state.modalView = .sendAsset
                                }
                            }
                            .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                        }
                        HStack {
//                            PButton(label: "Send to exchange", width: geometry.size.width/2, height: 32, fontSize: 12, enabled: false) {
//                                withAnimation(.easeInOut(duration: 0.4)) {
//
//                                }
//                            }
                            
                            PButton(label: "Withdraw from exchange", width: geometry.size.width/2, height: 32, fontSize: 12, enabled: false) {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    
                                }
                            }
                        }
                    }
                }
                
                Spacer().frame(height: 14)
                
                AssetRouteSwitch(route: $viewModel.route)
                
                switch viewModel.route {
                case .value:
                    MarketValueView(
                        timeframe: $viewModel.timeframe,
                        currency: state.wallet.currency,
                        totalValue: viewModel.totalValue,
                        change: viewModel.change,
                        high: viewModel.highValue,
                        low: viewModel.lowValue,
                        chartDataEntries: viewModel.chartDataEntries,
                        landscape: false,
                        type: .asset
                    )
                case .transactions:
                    RecentTxsView(viewModel: txsViewModel)
                        .frame(height: 425)
                        .transition(.identity)
                case .alerts:
                    AlertsView(coin: viewModel.coin)
                        .frame(height: 425)
                        .transition(.identity)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}

struct AssetViewPortrait_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalWalletBackground
            Color.black.opacity(0.58)
            AssetView(viewModel: AssetViewModel.config())
        }
        .frame(width: .infinity, height: 656)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
