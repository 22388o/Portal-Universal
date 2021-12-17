//
//  HeaderView.swift
//  Portal
//
//  Created by Farid on 07.07.2021.
//

import SwiftUI
import Combine

struct HeaderView: View {
    @ObservedObject private var viewModel: HeaderViewModel
    
    init(viewModel: HeaderViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                if viewModel.state.wallet.switchState == .wallet {
                    Button(action: {
                        withAnimation(.easeIn(duration: 3.0)) {
                            viewModel.state.modalView = .switchAccount
                        }
                    }, label: {
                        HStack {
                            Image("switchAccountsIcon")
                                .resizable()
                                .frame(width: 20, height: 20)
                                
                            Text("\(viewModel.accountName)")
                                .font(.mainFont(size: 14))
                        }
                        .foregroundColor(Color.white.opacity(0.82))
                    })
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("|")
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.white.opacity(0.6))
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            viewModel.state.showPortfolio.toggle()
                        }
                    }, label: {
                        Image("portfolioIcon")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(Color.white.opacity(0.82))
                            .offset(y: 2)
                    })
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()

                
                HStack {
                    if viewModel.isOffline {
                        Image("iconNoWiFi")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.red)
                    }
                    if viewModel.state.wallet.switchState == .wallet {
                        WalletCurrencyButton(currencies: viewModel.currencies, selectedCurrrency: $viewModel.state.wallet.currency).scaleEffect(0.85)
                        
                        Button(action: {
                            withAnimation(.easeIn(duration: 3.0)) {
                                viewModel.state.modalView = .accountSettings
                            }
                        }, label: {
                            Image("iconSettings")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(Color.white.opacity(0.82))
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Button(action: {
                        withAnimation(.easeIn(duration: 3.0)) {
                            viewModel.markAllNotificationsViewed()
                            viewModel.state.modalView = .allNotifications
                        }
                    }, label: {
                        ZStack(alignment: .topTrailing) {
                            Image("bellIcon")
                                .resizable()
                                .frame(width: 15, height: 18)
                            if viewModel.hasBadge {
                                Text("\(viewModel.newAlerts)")
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
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            AppSceneSwitch(state: $viewModel.state.wallet.switchState)
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(viewModel: HeaderViewModel.config())
    }
}
