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
    @StateObject private var viewModel: AssetViewModel
    @State private var channels: Bool = false
    @State private var showModal: Bool = false
    @State private var extendedBalance: Bool = false
        
    init(viewModel: AssetViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.94))
            
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                
                HStack {
                    ZStack {
                        if viewModel.adapterState != .synced {
                            CircularProgressBar(progress: $viewModel.syncProgress)
                                .frame(width: 26, height: 26)
                        }
                        CoinImageView(size: 24, url: viewModel.coin.icon)
                    }
                    .frame(width: 26, height: 26)
                    
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
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Button("Receive") {
                            viewModel.state.modalView = .receiveAsset
                        }
                        .buttonStyle(RoundedRectangleButtonStyle(hasShadow: false))
                        
                        Button("Send") {
                            viewModel.state.modalView = .sendAsset
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
                                
//                RecentTxsView(viewModel: viewModel.txsViewModel)
//                    .transition(.identity)
                
                if viewModel.txsViewModel.txs.isEmpty {
                    VStack {
                        Spacer()
                        Text("There are no transactions yet")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Spacer()
                    }
                } else {
                    VStack(spacing: 0) {
                        Text("Recent activity")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                            .padding(.vertical)
                        
                        ScrollView(showsIndicators: false) {
                            LazyVStack_(alignment: .leading, spacing: 0) {
                                Rectangle()
                                    .fill(Color.exchangerFieldBorder)
                                    .frame(height: 1)
                                
                                ForEach(viewModel.txsViewModel.txs, id: \.uid) { tx in
                                    Button {
                                        withAnimation(.easeIn(duration: 3.0)) {
                                            viewModel.txsViewModel.show(transaction: tx)
                                        }
                                    } label: {
                                        VStack(spacing: 4) {
                                            HStack(spacing: 8) {
                                                VStack {
                                                    Text(viewModel.txsViewModel.title(tx: tx))
                                                }
                                                .font(.mainFont(size: 12))
                                                .foregroundColor(Color.coinViewRouteButtonActive)
                                                Spacer()
                                                Text(viewModel.txsViewModel.date(tx: tx))
                                                    .lineLimit(1)
                                                    .font(.mainFont(size: 12))
                                                    .foregroundColor(Color.coinViewRouteButtonInactive)
                                            }
                                            
                                            HStack {
                                                Text(viewModel.txsViewModel.confimations(tx: tx))
                                                    .font(.mainFont(size: 12))
                                                    .foregroundColor(Color.coinViewRouteButtonInactive)
                                                Spacer()
                                            }
                                        }
                                        .frame(height: 56)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .id(tx.transactionHash)
                                    
                                    Rectangle()
                                        .fill(Color.exchangerFieldBorder)
                                        .frame(height: 1)
                                }
                            }
                        }
        #if os(macOS)
                        .frame(width: 256)
        #endif
        #if os(macOS)
                        PButton(label: "See all transactions", width: 256, height: 32, fontSize: 12, enabled: true) {
                            withAnimation(.easeIn(duration: 3.0)) {
                                state.modalView = .allTransactions(selectedTx: nil)
                            }
                        }
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                        .padding(.bottom, 41)
                        .padding(.top, 20)
        #endif
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
