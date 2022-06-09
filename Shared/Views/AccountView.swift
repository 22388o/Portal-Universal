//
//  AccountView.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var state = Portal.shared.state
    @StateObject var headerViewModel = HeaderViewModel.config()
    
    var containerZStackAlignment: Alignment {
        switch state.modalView {
        case .switchAccount:
            return .topLeading
        case .allNotifications, .accountSettings:
            return .topTrailing
        default:
            return .center
        }
    }
                
    var body: some View {
        ZStack(alignment: containerZStackAlignment) {
            switch state.wallet.switchState {
            case .wallet:
                Color.portalWalletBackground.allowsHitTesting(false)
            case .exchange, .dex:
                Color.portalSwapBackground.allowsHitTesting(false)
            }
            
            VStack(spacing: 0) {
                HeaderView(viewModel: headerViewModel)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 24)
                
                MainView()
                    .cornerRadius(8)
                    .padding([.leading, .bottom, .trailing], 24)
            }
            .blur(radius: state.modalView != .none ? 3 : 0)
            .allowsHitTesting(!(state.modalView != .none))
            
            if state.modalView != .none {
                Color.portalWalletBackground.opacity(0.72)
                    .transition(.identity)
                    .animation(nil)
                    .onTapGesture {
                        withAnimation {
                            state.modalView = .none
                        }
                    }
                WalletModalViews()
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .iPadLandscapePreviews()
    }
}
