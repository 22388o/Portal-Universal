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
            case .createAccount:
                CreateWalletScene()
            case .restoreAccount:
                RestoreWalletView()
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
