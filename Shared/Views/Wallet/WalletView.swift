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
//                    Text("Manage")
//                        .font(.mainFont(size: 14))
                }
                .padding([.top, .horizontal], 24)
                .padding(.bottom, 19)
                
                HStack {
                    Text("Asset")
                    Spacer()
                    Text("Value")
                        .offset(x: 17)
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
                    if state.searchRequest.isEmpty {
                        List(viewModel.items) { item in
                            AssetItemView(
                                viewModel: item.viewModel,
                                selected: state.selectedCoin.code == item.viewModel.coin.code,
                                onTap: {
                                    if item.viewModel.coin.code != state.selectedCoin.code {
                                        state.selectedCoin = item.viewModel.coin
                                    }
                                }
                            )
                            .id(item.id)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init(top: 4, leading: 4, bottom: 4, trailing: 4))
                        }
                        .id(viewModel.uuid)
                        .listStyle(SidebarListStyle())
                    } else {
                        List(viewModel.items.filter {
                                $0.viewModel.coin.code.lowercased().contains(state.searchRequest.lowercased()) ||
                                    $0.viewModel.coin.name.lowercased().contains(state.searchRequest.lowercased())}) { item in
                            AssetItemView(
                                viewModel: item.viewModel,
                                selected: state.selectedCoin.code == item.viewModel.coin.code,
                                onTap: {
                                    if item.viewModel.coin.code != state.selectedCoin.code {
                                        state.selectedCoin = item.viewModel.coin
                                    }
                                }
                            )
                            .id(item.id)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init(top: 4, leading: 4, bottom: 4, trailing: 4))
                        }
                        .id(viewModel.uuid)
                        .listStyle(SidebarListStyle())
                    }
                }
            }
            .frame(minWidth: 650)
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
