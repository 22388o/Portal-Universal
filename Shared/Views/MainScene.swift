//
//  MainScene.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct MainScene: View {
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
            switch state.mainScene {
            case .wallet:
                Color.portalWalletBackground.allowsHitTesting(false)
            case .exchange:
                Color.portalSwapBackground.allowsHitTesting(false)
            }
            
            VStack(spacing: 0) {
                HeaderView(viewModel: headerViewModel)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 24)
                
                MainView()
                    .transition(.opacity)
                    .cornerRadius(8)
                    .padding([.leading, .bottom, .trailing], 24)
            }
            .blur(radius: state.modalView != .none ? 4 : 0)
            .allowsHitTesting(!(state.modalView != .none))
            
            if state.modalView != .none {
                Color.white.opacity(0.01)
                    .onTapGesture {
                        withAnimation {
                            state.modalView = .none
                        }
                    }
                WalletModalViews()
                    .zIndex(1)
            }
        }
    }
}

struct MainScene_Previews: PreviewProvider {
    static var previews: some View {
        MainScene()
            .iPadLandscapePreviews()
    }
}
