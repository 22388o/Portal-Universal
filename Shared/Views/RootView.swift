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
            case .currentAccount:
                WalletScene()
                    .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                    .zIndex(6)
            case .createAccount:
                CreateWalletScene()
                    .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                    .zIndex(2)
            case .restoreAccount:
                RestoreWalletView()
                    .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
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
