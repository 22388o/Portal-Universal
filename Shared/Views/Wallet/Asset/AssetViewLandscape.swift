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
                        PButton(label: "Receive", width: 124, height: 32, fontSize: 12, enabled: true) {
                            withAnimation(.easeIn(duration: 3.0)) {
                                state.modalView = .receiveAsset
                            }
                        }
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                        
                        PButton(label: "Send", width: 124, height: 32, fontSize: 12, enabled: viewModel.canSend) {
                            withAnimation(.easeIn(duration: 3.0)) {
                                state.modalView = .sendAsset
                            }
                        }
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                    }
                    PButton(label: "Send to exchange", width: 256, height: 32, fontSize: 12, enabled: false) {
                        withAnimation(.easeIn(duration: 0)) {
                            
                        }
                    }
                    PButton(label: "Channels", width: 256, height: 32, fontSize: 12, enabled: true) {
                        withAnimation(.easeIn(duration: 3.0)) {
                            state.modalView = .channels
                        }
                    }
                    .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                }
                
                Spacer().frame(height: 10)
                
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
                        landscape: true,
                        type: .asset
                    )
                    
#if os(macOS)
                    
                    ScrollView(showsIndicators: false) {
                        Spacer().frame(height: 30)
                        
                        VStack(spacing: 12) {
                            VStack(spacing: 8) {
                                Text("MarketCap")
                                    .font(Font.mainFont())
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.5))
                                Text(viewModel.marketCap)
                                    .font(Font.mainFont(size: 15))
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.8))
                            }
                            VStack(spacing: 8) {
                                Text("24h volume")
                                    .font(Font.mainFont())
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.5))
                                Text(viewModel.volume24h)
                                    .font(Font.mainFont(size: 15))
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.8))
                            }
                            VStack(spacing: 8) {
                                Text("Total supply")
                                    .font(Font.mainFont())
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.5))
                                Text(viewModel.totalSupply)
                                    .font(Font.mainFont(size: 15))
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.8))
                            }
                            VStack(spacing: 8) {
                                Text("Max supply")
                                    .font(Font.mainFont())
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.5))
                                Text(viewModel.maxSupply)
                                    .font(Font.mainFont(size: 15))
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.8))
                            }
                            VStack(spacing: 8) {
                                Text("ATH price")
                                    .font(Font.mainFont())
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.5))
                                Text(viewModel.athPrice)
                                    .font(Font.mainFont(size: 15))
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.8))
                            }
                            VStack(spacing: 8) {
                                Text("Percent from ATH price")
                                    .font(Font.mainFont())
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.5))
                                Text(viewModel.percentFromPriceAth)
                                    .font(Font.mainFont(size: 15))
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.8))
                            }
                            VStack(spacing: 8) {
                                Text("ATH date")
                                    .font(Font.mainFont())
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.5))
                                Text(viewModel.athDate)
                                    .font(Font.mainFont(size: 15))
                                    .foregroundColor(Color.lightActiveLabel.opacity(0.8))
                            }
                        }
                    }
                    .padding(.vertical, 15)
                    
#endif
                    
                case .transactions:
                    RecentTxsView(viewModel: viewModel.txsViewModel)
                        .transition(.identity)
                case .alerts:
                    AlertsView(coin: viewModel.coin)
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
