//
//  WalletView.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct WalletView: View {
    @ObservedObject var state: PortalState
    @ObservedObject var viewModel: WalletViewModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    AssetSearchField(search: $state.searchRequest)
                    FiatCurrencyButton(currencies: viewModel.fiatCurrencies, selectedCurrrency: $state.fiatCurrency)
                }
                .padding([.top, .horizontal], 24)
                .padding(.bottom, 19)
                
                HStack {
                    Text("Asset")
                    Spacer()
                    Text("Value")
                    Spacer()
                    Text("24h Change")
                }
                .font(.mainFont())
                .foregroundColor(Color.white.opacity(0.5))
                .padding(.horizontal, 55)
                
                Divider()
                    .background(Color.white.opacity(0.11))
                    .padding(.top, 12)
                
                if viewModel.items.isEmpty {
                    VStack {
                        Spacer()
                        Text("Loading wallet...")
                            .font(.mainFont(size: 20, bold: false))
                            .foregroundColor(Color.white.opacity(0.8))
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            if state.searchRequest.isEmpty {
                                ForEach(viewModel.items, id: \.coin.code) { item in
                                    AssetItemView(
                                        coin: item.coin,
                                        adapter: item.adapter,
                                        selected: state.selectedCoin.code == item.coin.code,
                                        fiatCurrency: state.fiatCurrency,
                                        onTap: {
                                            if item.coin.code != state.selectedCoin.code {
                                                state.selectedCoin = item.coin
                                            }
                                        }
                                    )
                                    .padding(.horizontal, 18)
                                }
                            } else {
                                ForEach(viewModel.items.filter { $0.coin.code.lowercased().contains(state.searchRequest.lowercased()) || $0.coin.name.lowercased().contains(state.searchRequest.lowercased())}, id: \.coin.code) { item in
                                    AssetItemView(
                                        coin: item.coin,
                                        adapter: item.adapter,
                                        selected: state.selectedCoin.code == item.coin.code,
                                        fiatCurrency: state.fiatCurrency,
                                        onTap: {
                                            if item.coin.code != state.selectedCoin.code {
                                                state.selectedCoin = item.coin
                                            }
                                        }
                                    )
                                    .padding(.horizontal, 18)
                                }
                            }
                        }
                        .offset(y: 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 6)
                }
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalWalletBackground
            Color.black.opacity(0.58)
            WalletView(state: Portal.shared.state, viewModel: WalletViewModel.config())
        }
        .frame(width: .infinity, height: 430)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
