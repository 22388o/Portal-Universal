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
    
    @EnvironmentObject private var marketDataProvider: MarketDataProvider
    @ObservedObject private var state = Portal.shared.state
        
    var body: some View {
        ZStack {
            Color.portalWalletBackground
            
            Group {
                switch state.current {
                case .currentWallet:
                    WalletScene()

                    if loaderIsPresented {
                        PortalLoader()
                            .scaleEffect(hideLoader ? 10 : 1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.portalWalletBackground)
                            .opacity(hideLoader ? 0 : 1)
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
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                withAnimation {
                    hideLoader.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                loaderIsPresented.toggle()
                hideLoader.toggle()
            }
        })
        .onReceive(Portal.shared.accountManager.onActiveAccountUpdatePublisher) { account in
            if account != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        state.current = .currentWallet
                    }
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .iPadLandscapePreviews()
    }
}
