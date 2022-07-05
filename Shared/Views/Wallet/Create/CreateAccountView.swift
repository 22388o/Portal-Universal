//
//  CreateAccountView.swift
//  Portal
//
//  Created by Farid on 04.04.2021.
//

import SwiftUI

struct CreateAccountView: View {
    @Binding var scene: PortalState.Scene
    
    @StateObject private var viewModel = CreateAccountViewModel(
        type: CreateAccountViewModel.mnemonicAccountType()
    )
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            #if os(macOS)
            Color.portalWalletBackground
            
            HStack(spacing: 12) {
                Group {
                    Text("Welcome to Portal")
                        .font(.mainFont(size: 14, bold: true))
                    Group {
                        Text("|")
                        Text("Set up a wallet")
                    }
                    .font(.mainFont(size: 14))
                }
                .foregroundColor(.white)
            }
            .padding(.top, 35)
            
            if Portal.shared.accountManager.activeAccount != nil {
                HStack {
                    PButton(label: "Go back", width: 80, height: 30, fontSize: 12, enabled: true) {
                        withAnimation {
                            Portal.shared.state.rootView = .account
                        }
                    }
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.leading, 30)
            }
            #endif
            ZStack {
                #if os(macOS)
                Color.black.opacity(0.58)
                #endif
                HStack(spacing: 0) {
                    #if os(macOS)
                    if viewModel.step == .name {
                        TopCoinView()
                            .frame(width: 312)
                            .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                    }
                    #endif
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.white)
                            .cornerRadius(5)
                            .padding(viewModel.step == .name ? [.vertical, .trailing] : .all, 8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Group {
                            switch viewModel.step {
                            case .name:
                                AccountNameView(scene: $scene, viewModel: viewModel)
                                    .scaleEffect(0.85)
                            case .seed:
                                StoreSeedView(viewModel: viewModel)
                            case .test:
                                SeedTestView(viewModel: viewModel)
                                    .scaleEffect(0.85)
                            case .confirmation:
                                EmptyView()
                            }
                        }
                        .zIndex(1)
                        .transition(
                            AnyTransition.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            )
                            .combined(with: .opacity)
                        )
                        .padding(.horizontal, 40)
                    }
                    .zIndex(1)
                }
            }
            .cornerRadius(8)
            .padding(EdgeInsets(top: 88, leading: 24, bottom: 24, trailing: 24))
        }
    }
}

struct CreateAccountScene_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView(scene: .constant(.createAccount))
            .iPadLandscapePreviews()
    }
}
