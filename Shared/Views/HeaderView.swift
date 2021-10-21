//
//  HeaderView.swift
//  Portal
//
//  Created by Farid on 07.07.2021.
//

import SwiftUI
import Combine

struct HeaderView: View {
    @ObservedObject private var viewModel: PortalHeaderViewModel
    
    init(viewModel: PortalHeaderViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            HStack {
                if viewModel.state.mainScene == .wallet {
                    Button(action: {
                        withAnimation(.easeIn(duration: 1.2)) {
                            viewModel.state.switchWallet.toggle()
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
                }
                
                Spacer()
                
                HStack {
                    if viewModel.isOffline {
                        Text("You are not connected to the Internet")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.red)
                    }
                    Button(action: {
                        withAnimation(.easeIn(duration: 0.4)) {
                            viewModel.markAllNotificationsViewed()
                            viewModel.state.allNotifications.toggle()
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
            
            AppSceneSwitch(state: $viewModel.state.mainScene)            
        }
        .frame(minWidth: 600)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(viewModel: PortalHeaderViewModel.config())
    }
}
