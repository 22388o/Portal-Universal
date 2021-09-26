//
//  MarketLimitSwitch.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import SwiftUI

struct MarketLimitSwitch: View {
    @Binding var state: MarketLimitSwitchState
    
    var body: some View {
        HStack(spacing: 0) {
            HStack {
                Spacer()

                Text("Market")
                    .font(.mainFont(size: 12))
                    .foregroundColor(
                        state == .market ? Color.coinViewRouteButtonActive : Color.coinViewRouteButtonActive.opacity(0.47)
                    )
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .background(state == .market ? Color(red: 238/255, green: 235/255, blue: 239/255) : Color(red: 243/255, green: 240/255, blue: 242/255))
            .onTapGesture {
                withAnimation {
                    state = .market
                }
            }
                        
            HStack {
                Spacer()
                Text("Limit")
                    .font(.mainFont(size: 12))
                    .foregroundColor(
                        state == .limit ? Color.coinViewRouteButtonActive : Color.coinViewRouteButtonActive.opacity(0.47)
                    )
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .background(state == .limit ? Color(red: 238/255, green: 235/255, blue: 239/255) : Color(red: 243/255, green: 240/255, blue: 242/255))
            .onTapGesture {
                withAnimation {
                    state = .limit
                }
            }
        }
        .modifier(SmallTextFieldModifier(cornerRadius: 16))
    }
}

struct MarketLimitSwitch_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MarketLimitSwitch(state: .constant(.market))
            MarketLimitSwitch(state: .constant(.limit))
        }
        .padding()
        .background(Color.white)
    }
}
