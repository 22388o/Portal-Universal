//
//  WalletHeaderView.swift
//  Portal
//
//  Created by Farid on 07.07.2021.
//

import SwiftUI

struct WalletHeaderView: View {
    @Binding var state: Scenes
    @ObservedObject private var viewModel: WalletSceneViewModel
    @ObservedObject private var notificationService: NotificationService
    
    init(state: Binding<Scenes>, viewModel: WalletSceneViewModel) {
        self._state = state
        self.viewModel = viewModel
        self.notificationService = Portal.shared.notificationService
    }
    
    var body: some View {
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
                
                if state == .wallet {
                    HStack(spacing: 2) {
                        Image("securityOn")
                        Text("Your wallet is stored locally")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
            }
            
            AppSceneSwitch(state: $state)
        }
    }
}

struct WalletHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        WalletHeaderView(state: .constant(.wallet), viewModel: .init(wallet: WalletMock(), userCurrrency: USD, allCurrencies: []))
    }
}
