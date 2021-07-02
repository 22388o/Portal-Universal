//
//  RootView.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

struct RootView: View {
    @State private var marketDataLoaded: Bool = false
    @State private var loadingAnimationStarted = false
    
    @EnvironmentObject private var walletService: WalletsService
    @EnvironmentObject private var marketData: MarketDataRepository
        
    var body: some View {
        ZStack(alignment: .top) {
            Color.portalWalletBackground
            
            if marketDataLoaded {
                Group {
                    switch walletService.state {
                    case .currentWallet:
                        if let wallet = walletService.currentWallet {
                            let fiat = marketData.fiatCurrencies.first(where: { $0.code == wallet.fiatCurrencyCode }) ?? USD
                            WalletScene(wallet: wallet, fiatCurrency: fiat)
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
            } else {
                VStack {
                    Spacer()
                    Text("LOADING")
                        .font(.mainFont(size: 18))
                        .foregroundColor(.white)
                        .scaleEffect(loadingAnimationStarted ? 1 : 0.5)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), {
                                loadingAnimationStarted.toggle()
                            })
                        }
                    Spacer()
                }
            }
        }
        .onReceive(marketData.$tickers.dropFirst(), perform: { tickers in
            guard let tickers = tickers, !tickers.isEmpty else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                marketDataLoaded.toggle()
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
