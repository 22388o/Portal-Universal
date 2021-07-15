//
//  RootView.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

struct RootView: View {
    @State private var hideLoader = false
    @State private var loaderIsPresented = true
    
    @EnvironmentObject private var walletService: WalletsService
    @EnvironmentObject private var marketDataProvider: MarketDataProvider
        
    var body: some View {
        ZStack {
            Color.portalWalletBackground
            
            Group {
                switch walletService.state {
                case .currentWallet:
                    if let wallet = walletService.currentWallet {
                        let fiatCurrencies = marketDataProvider.fiatCurrencies
                        let fiat = fiatCurrencies.first(where: { $0.code == wallet.fiatCurrencyCode }) ?? USD

                        WalletScene(viewModel: .init(wallet: wallet, userCurrrency: fiat, allCurrencies: fiatCurrencies))
                        
                        if loaderIsPresented {
                            PortalLoader()
                                .scaleEffect(hideLoader ? 10 : 1)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.portalWalletBackground)
                                .opacity(hideLoader ? 0 : 1)
                        }
                    } else {
                        Text("Something went wrong")
                    }
                case .createWallet:
                    CreateWalletScene()
                case .restoreWallet:
                    RestoreWalletView()
                }
            }
            .transition(AnyTransition.scale.combined(with: .opacity))
        }
        .onReceive(Portal.shared.$marketDataReady.dropFirst(), perform: { dataIsLoaded in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    hideLoader.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                loaderIsPresented.toggle()
                hideLoader.toggle()
            }
        })
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .iPadLandscapePreviews()
    }
}
