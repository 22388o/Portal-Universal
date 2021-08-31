//
//  RootView.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

struct RootView: View {
    @ObservedObject private var state = Portal.shared.state
        
    var body: some View {
        ZStack {
            Color.portalWalletBackground
            
            switch state.current {
            case .starting:
                Color.clear
            case .currentAccount:
                WalletScene()
                    .transition(AnyTransition.opacity)
                    .zIndex(6)
            case .createAccount:
                CreateWalletScene()
                    .transition(AnyTransition.opacity)
                    .zIndex(2)
            case .restoreAccount:
                RestoreWalletView()
                    .transition(AnyTransition.opacity)
                    .zIndex(3)
            }
        }
        .isLocked(locked: $state.loading)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .iPadLandscapePreviews()
    }
}
