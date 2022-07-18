//
//  RootView.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

struct RootView: View {
    @ObservedObject private var state = Portal.shared.state
    private var isIPhone: Bool = false
    
    init() {
        #if os(iOS)
        isIPhone = UIDevice.current.model.hasPrefix("iPhone")
        #endif
    }
        
    var body: some View {
        ZStack {
            Color.portalWalletBackground
            
            switch state.rootView {
            case .idle:
                Color.clear
            case .account:
                if isIPhone {
#if os(iOS)
                    AssetViewPhone(viewModel: AssetViewModel.config())
                        .transition(.identity)
#endif
                } else {
                    AccountView()
                        .transition(.identity)
                }
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
