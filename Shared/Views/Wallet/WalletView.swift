//
//  WalletView.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct WalletItem {
    let coin: Coin
    let adapter: IBalanceAdapter
}

class WalletViewModel: ObservableObject {
    @Published var items: [WalletItem] = []
    @Published var fiatCurrencies: [FiatCurrency] = []
    
    @ObservedObject var state: PortalState
        
    init(wallets: [Wallet], adapterManager: IAdapterManager, state: PortalState, currencies: [FiatCurrency]) {
        self.state = state
        
        items = wallets.compactMap({ wallet in
            let coin = wallet.coin
            guard let adapter = adapterManager.balanceAdapter(for: wallet) else { return nil }
            return WalletItem(coin: coin, adapter: adapter)
        })
        
        fiatCurrencies = Portal.shared.marketDataProvider.fiatCurrencies
    }
}

extension WalletViewModel {
    static func config() -> WalletViewModel {
        let adapterManager = Portal.shared.adapterManager
        let walletManager = Portal.shared.walletManager
        let state = Portal.shared.state
        let fiatCurrencies = Portal.shared.marketDataProvider.fiatCurrencies
        
        return WalletViewModel(
            wallets: walletManager.activeWallets,
            adapterManager: adapterManager,
            state: state,
            currencies: fiatCurrencies
        )
    }
}

struct WalletView: View {
    @ObservedObject private var viewModel: WalletViewModel
    
    init() {
        self.viewModel = WalletViewModel.config()
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    AssetSearchField(search: $viewModel.state.searchRequest)
                    FiatCurrencyButton(currencies: viewModel.fiatCurrencies, selectedCurrrency: .constant(USD))
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
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if viewModel.state.searchRequest.isEmpty {
                            ForEach(viewModel.items, id: \.coin.code) { item in
                                AssetItemView(
                                    coin: item.coin,
                                    adapter: item.adapter,
                                    selected: viewModel.state.selectedCoin.code == item.coin.code,
                                    fiatCurrency: USD,
                                    onTap: {
                                        if item.coin.code != viewModel.state.selectedCoin.code {
                                            viewModel.state.selectedCoin = item.coin
                                        }
                                    }
                                )
                                .padding(.horizontal, 18)
                            }
                        } else {
                            ForEach(viewModel.items.filter { $0.coin.code.lowercased().contains(viewModel.state.searchRequest.lowercased()) || $0.coin.name.lowercased().contains(viewModel.state.searchRequest.lowercased())}, id: \.coin.code) { item in
                                AssetItemView(
                                    coin: item.coin,
                                    adapter: item.adapter,
                                    selected: viewModel.state.selectedCoin.code == item.coin.code,
                                    fiatCurrency: USD,
                                    onTap: {
                                        if item.coin.code != viewModel.state.selectedCoin.code {
                                            viewModel.state.selectedCoin = item.coin
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

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalWalletBackground
            Color.black.opacity(0.58)
            WalletView()
        }
        .frame(width: .infinity, height: 430)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
