//
//  WalletHeaderView.swift
//  Portal
//
//  Created by Farid on 07.07.2021.
//

import SwiftUI

struct WalletHeaderView: View {
    @Binding var state: Scenes
    @ObservedObject private var notificationService = Portal.shared.notificationService
    @ObservedObject private var portalState = Portal.shared.state
    private let name: String
    
    init(state: Binding<Scenes>, accountName: String) {
        self._state = state
        self.name = accountName
    }
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    withAnimation {
                        portalState.switchWallet.toggle()
                    }
                }, label: {
                    HStack {
                        Image(systemName: "arrow.up.right.and.arrow.down.left.rectangle")
                        Text("\(name)")
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
                    portalState.allNotifications.toggle()
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
        WalletHeaderView(state: .constant(.wallet), accountName: "Mocked")
    }
}
