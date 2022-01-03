//
//  AppSceneSwitch.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct AppSceneSwitch: View {
    private let switchWidth: CGFloat = 256
    
    @Binding var state: HeaderSwitchState
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.14))
                .shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 2)
            
            ZStack(alignment: zStackAlignment) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.83))
                    .frame(width: switchWidth / CGFloat(HeaderSwitchState.allCases.count))
                    .shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 2)
                
                HStack(spacing: 0) {
                    HStack {
                        Spacer()

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
                        Text("Exchange")
                            .font(.mainFont(size: 12))
                            .foregroundColor(
                                state == .exchange ? Color.walletExchangeSwitchActentLabel : Color.white.opacity(0.82)
                            )
                        Spacer()
                    }
                    .onTapGesture {
                        withAnimation {
                            state = .exchange
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Text("DEX")
                            .font(.mainFont(size: 12))
                            .foregroundColor(
                                state == .dex ? Color.walletExchangeSwitchActentLabel : Color.white.opacity(0.82)
                            )
                        Spacer()
                    }
                    .onTapGesture {
                        withAnimation {
                            state = .dex
                        }
                    }
                }
            }
        }
        .frame(width: switchWidth, height: 40)
    }
    
    private var zStackAlignment: Alignment {
        switch state {
        case .wallet:
            return .leading
        case .exchange:
            return .center
        case .dex:
            return .trailing
        }
    }
}

struct AppSceneSwitch_Previews: PreviewProvider {
    static var previews: some View {
        AppSceneSwitch(state: .constant(.wallet))
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .background(Color.portalWalletBackground)
    }
}
