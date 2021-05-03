//
//  AppSceneSwitch.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct AppSceneSwitch: View {
//    enum Scenes {
//        case wallet, swap
//    }
//    
    @Binding var state: WalletScene.Scenes
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.14))
                .shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 2)
            
            ZStack(alignment: state == .wallet ? .leading : .trailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.83))
                    .frame(width: 128)
                    .shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 2)
                
                HStack(spacing: 0) {
                    HStack {
                        Spacer()
//                        Image("iconSafeSmall")
//                            .renderingMode(.template)
//                            .accentColor(
//                                state == .wallet ? Color.black : Color.white
//                            )
                        Text("My wallet")
                            .font(.mainFont(size: 12))
                            .foregroundColor(
                                state == .wallet ? Color.walletExchangeSwitchActentLabel : Color.white.opacity(0.82)
                            )
                        Spacer()
                    }
                    .onTapGesture {
                        withAnimation {
                            state = .wallet
                        }
                    }
                    
                    HStack {
                        Spacer()
//                        Image("iconSafeSmall")
//                            .renderingMode(.template)
//                            .accentColor(
//                                state == .swap ? Color.black : Color.white
//                            )
                        Text("Atomic swap")
                            .font(.mainFont(size: 12))
                            .foregroundColor(
                                state == .swap ? Color.walletExchangeSwitchActentLabel : Color.white.opacity(0.82)
                            )
                        Spacer()
                    }
                    .onTapGesture {
                        withAnimation {
                            state = .swap
                        }
                    }
                }
            }
        }
        .frame(width: 256, height: 40)
    }
}

struct WalletExchangeSwitch_Previews: PreviewProvider {
    static var previews: some View {
        AppSceneSwitch(state: .constant(.wallet))
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .background(Color.portalWalletBackground)
    }
}
