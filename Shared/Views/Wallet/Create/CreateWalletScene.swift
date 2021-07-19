//
//  CreateWalletScene.swift
//  Portal
//
//  Created by Farid on 04.04.2021.
//

import SwiftUI

struct CreateWalletScene: View {
    @ObservedObject private var viewModel: CreateWalletSceneViewModel
    
    init() {
        self.viewModel = CreateWalletSceneViewModel()
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
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
                            Portal.shared.state.current = .currentWallet
                        }
                    }
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.leading, 30)
            }
            
            ZStack {
                Color.black.opacity(0.58)
                                
                HStack(spacing: 0) {
                    if viewModel.walletCreationStep == .createWalletName {
                        TopCoinView()
                            .frame(width: 312)
                            .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.white)
                            .cornerRadius(5)
                            .padding(viewModel.walletCreationStep == .createWalletName ? [.vertical, .trailing] : .all, 8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Group {
                            switch viewModel.walletCreationStep {
                            case .createWalletName:
                                CreateWalletNameView(viewModel: viewModel)
                            case .seed:
                                StoreSeedView(viewModel: viewModel)
                            case .test:
                                SeedTestView(viewModel: viewModel)
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

struct CreateWalletScene_Previews: PreviewProvider {
    static var previews: some View {
        CreateWalletScene()
            .iPadLandscapePreviews()
    }
}
