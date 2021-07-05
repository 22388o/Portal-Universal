//
//  WalletScene.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct WalletScene: View {
    @ObservedObject private var viewModel: WalletSceneViewModel
    @ObservedObject private var notificationService: NotificationService
    @State private var state: Scenes = .wallet
            
    init(wallet: IWallet, fiatCurrency: FiatCurrency) {
        notificationService = NotificationService.shared
        viewModel = .init(wallet: wallet, fiatCurrency: fiatCurrency)
    }
    
    var body: some View {
        ZStack(alignment: viewModel.switchWallet || viewModel.allNotifications ? .topLeading : .center) {
            switch state {
            case .wallet:
                Color.portalWalletBackground.allowsHitTesting(false)
            case .swap:
                Color.portalSwapBackground.allowsHitTesting(false)
            }
            
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                viewModel.switchWallet.toggle()
                            }
                        }, label: {
                            HStack {
                                Image(systemName: "arrow.up.right.and.arrow.down.left.rectangle")
                                Text("\(viewModel.walletName)")
                                    .font(.mainFont(size: 14))
                            }
                            .foregroundColor(Color.white.opacity(0.82))
                        })
                        
                        Text("|")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.white.opacity(0.6))
                        
//                        if state != .swap && viewModel.sceneState != .full {
//                            Button(action: {
//                                withAnimation {
//                                    if viewModel.sceneState == .walletPortfolio {
//                                        viewModel.sceneState = .walletAsset
//                                    } else {
//                                        viewModel.sceneState = .walletPortfolio
//                                    }
//                                }
//                            }, label: {
//                                HStack {
//                                    Image(systemName: "aqi.medium")
//                                    Text("Portfolio")
//                                        .font(.mainFont(size: 14))
//                                }
//                                .foregroundColor(Color.white.opacity(0.82))
//                            })
//                        }
//
//                        Text("|")
//                            .font(.mainFont(size: 12))
//                            .foregroundColor(Color.white.opacity(0.6))
                        
                        Button(action: {
                            notificationService.markAllAlertsViewed()
                            viewModel.allNotifications.toggle()
                        }, label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                if !notificationService.alertsBeenSeen && notificationService.newAlerts > 0 {
                                    Text("\(notificationService.newAlerts)")
                                        .lineLimit(1)
                                        .padding(.horizontal, 3)
                                        .frame(minWidth: 16)
                                        .frame(height: 16)
                                        .font(.mainFont(size: 8))
                                        .foregroundColor(Color.walletGradientTop)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .offset(x: 3, y: -5)
                                }
                            }
                            .foregroundColor(Color.white.opacity(0.82))
                            .frame(minWidth: 30)
                        })
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image("securityOn")
                            Text("Your wallet is stored locally")
                                .font(.mainFont(size: 12))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                    }
                    
                    AppSceneSwitch(state: $state)
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 24)
                
                ZStack {
                    Color.black.opacity(0.58).allowsHitTesting(false)
                    
                    switch state {
                    case .wallet:
                        HStack(spacing: 0) {
                            switch viewModel.sceneState {
                            case .full:
                                PortfolioView(viewModel: viewModel.portfolioViewModel)
                                WalletView(viewModel: viewModel)
                                AssetView(sceneViewModel: viewModel, fiatCurrency: viewModel.fiatCurrency)
                                    .padding([.top, .trailing, .bottom], 8)
                            default:
                                if viewModel.sceneState == .walletPortfolio {
                                    PortfolioView(viewModel: viewModel.portfolioViewModel)
                                        .transition(.move(edge: .leading))
                                }
                                WalletView(viewModel: viewModel)
                                if viewModel.sceneState == .walletAsset {
                                    AssetView(sceneViewModel: viewModel, fiatCurrency: viewModel.fiatCurrency)
                                        .padding([.top, .trailing, .bottom], 8)
                                        .transition(.move(edge: .trailing))
                                }
                            }
                        }
                    case .swap:
                        Text("Swap")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }
                .cornerRadius(8)
                .padding([.leading, .bottom, .trailing], 24)
            }
            .blur(radius: viewModel.modalViewIsPresented ? 6 : 0)
            .scaleEffect(viewModel.scaleEffectRation)
            .allowsHitTesting(!viewModel.modalViewIsPresented)
            
            Group {
                Group {
                    if viewModel.sendAsset {
                        SendAssetView(
                            wallet: viewModel.wallet,
                            asset: viewModel.selectedAsset,
                            fiatCurrency: viewModel.fiatCurrency,
                            presented: $viewModel.sendAsset
                        )
                    }
                    if viewModel.receiveAsset {
                        ReceiveAssetsView(asset: viewModel.selectedAsset, presented: $viewModel.receiveAsset)
                    }
                    if viewModel.allTransactions {
                        AssetTxView(asset: viewModel.selectedAsset, presented: $viewModel.allTransactions)
                    }
                    if viewModel.createAlert {
                        CreateAlertView(asset: viewModel.selectedAsset, presented: $viewModel.createAlert)
                    }
                }
                .transition(.scale)
                
                if viewModel.switchWallet {
                    SwitchWalletsView(presented: $viewModel.switchWallet)
                        .padding(.top, 78)
                        .padding(.leading, 24)
                }
                
                if viewModel.allNotifications {
                    NotificationsView(presented: $viewModel.allNotifications)
                        .padding(.top, 70)
                        .padding(.leading, 20)
                }
            }
            .allowsHitTesting(true)
            .zIndex(1)
        }
    }
}

struct MainScene_Previews: PreviewProvider {
    static var previews: some View {
        WalletScene(wallet: WalletMock(), fiatCurrency: USD)
            .iPadLandscapePreviews()
    }
}
