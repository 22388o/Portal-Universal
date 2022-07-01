//
//  AssetViewPhone.swift
//  Portal
//
//  Created by Farid on 10.04.2021.
//

import SwiftUI
import Charts
import Coinpaprika

struct AssetViewPhone: View {
    @ObservedObject private var viewModel: AssetViewModel
    @State private var channels: Bool = false
    @State private var showModal: Bool = false
    @State private var extendedBalance: Bool = false
        
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
                    Text("\(viewModel.balance) \(viewModel.coin.code)")
                        .font(.mainFont(size: 28))
                        .foregroundColor(Color.assetValueLabel)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                extendedBalance.toggle()
                            }
                        }
                }
                
                if extendedBalance {
                    VStack {
                        HStack {
                            Text("On-chain")
                                .font(.mainFont(size: 12))
                                .foregroundColor(Color.gray)
                            Spacer()
                            Text("\(viewModel.balance) \(viewModel.coin.code)")
                                .font(.mainFont(size: 22))
                                .foregroundColor(Color.assetValueLabel)
                        }
                        HStack {
                            Text("Lightning")
                                .font(.mainFont(size: 12))
                                .foregroundColor(Color.gray)
                            Spacer()
                            Text("0")
                                .font(.mainFont(size: 22))
                                .foregroundColor(Color.assetValueLabel)
                        }
                    }
//                    .transition(.scale.combined(with: .opacity))
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Button("Receive") {
                            viewModel.state.modalView = .receiveAsset
                        }
                        .buttonStyle(RoundedRectangleButtonStyle(hasShadow: false))
                        
                        Button("Send") {
                            withAnimation(.easeIn(duration: 3.0)) {
                                viewModel.state.modalView = .sendAsset
                            }
                        }
                        .buttonStyle(RoundedRectangleButtonStyle())
                    }
                    
                    if viewModel.coin == .bitcoin() {
                        Button("Manage channels") {
                            viewModel.state.modalView = .channels
                        }
                        .buttonStyle(RoundedRectangleButtonStyle())
                    } else {
                        Button("Send to exchange") {
                            withAnimation {

                            }
                        }
                        .buttonStyle(RoundedRectangleButtonStyle())
                    }
                }
                .padding(.top, 15)
                .sheet(isPresented: $showModal) {
                    switch viewModel.state.modalView {
                    case .receiveAsset:
                        TabView {
                            ReceiveAssetsView(coin: .bitcoin())
                            CreateInvoiceView(viewState: .constant(.root))
                        }
                        .tabViewStyle(PageTabViewStyle())
                    case .sendAsset:
                        TabView {
                            SendAssetView(coin: .bitcoin(), currency: .fiat(USD))
                            PayInvoiceView(viewState: .constant(.root))
                        }
                        .tabViewStyle(PageTabViewStyle())
                    case .channels:
                        ManageChannelsView(viewState: .constant(.root))
                    default:
                        EmptyView()
                    }
                }
                .onReceive(viewModel.state.$modalView.dropFirst()) { _ in
                    showModal = true
                }
                
                Spacer().frame(height: 10)
                
//                    AssetRouteSwitch(route: $viewModel.route)
                
//                    switch viewModel.route {
//                    case .value:
//                        MarketValueView(
//                            timeframe: $viewModel.timeframe,
//                            currency: state.wallet.currency,
//                            totalValue: viewModel.totalValue,
//                            change: viewModel.change,
//                            high: viewModel.highValue,
//                            low: viewModel.lowValue,
//                            chartDataEntries: viewModel.chartDataEntries,
//                            landscape: true,
//                            type: .asset
//                        )
//                    case .transactions:
//                        RecentTxsView(viewModel: viewModel.txsViewModel)
//                            .transition(.identity)
//                    case .alerts:
//                        AlertsView(coin: viewModel.coin)
//                            .transition(.identity)
//                    }
                
                RecentTxsView(viewModel: viewModel.txsViewModel)
                    .transition(.identity)
            }
            .padding(.horizontal, 24)
        }
    }
}

struct AssetViewPhone_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalWalletBackground
            Color.black.opacity(0.58)
            AssetViewPhone(viewModel: AssetViewModel.config())
        }
        .frame(width: 304, height: 656)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
