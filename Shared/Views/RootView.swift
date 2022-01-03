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
            
            switch state.rootView {
            case .idle:
                Color.clear
            case .account:
                AccountView()
                    .transition(.identity)
	            case .createAccount:
                CreateAccountView(scene: $state.rootView)
                    .transition(.scale(scale: 0.99))
            case .restoreAccount:
                RestoreAccountView()
                    .transition(.scale(scale: 0.99))
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
