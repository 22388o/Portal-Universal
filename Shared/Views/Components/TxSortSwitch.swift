//
//  TxSortSwitch.swift
//  Portal
//
//  Created by Farid on 29.06.2021.
//

import SwiftUI

struct TxSortSwitch: View {
    @Binding var state: TxSortState
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                state = .all
            }) {
                VStack(spacing: 4) {
                    Text(TxSortState.all.description)
                        .foregroundColor(state == .all ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                    if state == .all {
                        Rectangle()
                            .fill(Color.coinViewRouteButtonActive)
                            .frame(height: 3)
                    } else {
                        Spacer().frame(height: 3)
                    }
                }
            }
            .frame(width: 100)
            
            Button(action: {
                state = .sent
            }) {
                VStack(spacing: 4) {
                    Text(TxSortState.sent.description)
                        .foregroundColor(state == .sent ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                    if state == .sent {
                        Rectangle()
                            .fill(Color.coinViewRouteButtonActive)
                            .frame(height: 3)
                    } else {
                        Spacer().frame(height: 3)
                    }
                }
            }
            .frame(width: 75)
            
            Button(action: {
                state = .received
            }) {
                VStack(spacing: 4) {
                    Text(TxSortState.received.description)
                        .foregroundColor(state == .received ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                    if state == .received {
                        Rectangle()
                            .fill(Color.coinViewRouteButtonActive)
                            .frame(height: 3)
                    } else {
                        Spacer().frame(height: 3)
                    }
                }
            }
            .frame(width: 75)
            
            Button(action: {
                state = .swapped
            }) {
                VStack(spacing: 4) {
                    Text(TxSortState.swapped.description)
                        .foregroundColor(state == .swapped ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                    if state == .swapped {
                        Rectangle()
                            .fill(Color.coinViewRouteButtonActive)
                            .frame(height: 3)
                    } else {
                        Spacer().frame(height: 3)
                    }
                }
            }
            .frame(width: 75)
            
            Spacer()
        }
        .buttonStyle(BorderlessButtonStyle())
        .font(.mainFont(size: 14))
        .padding(.horizontal, 32)
    }
}
struct TxSortSwitch_Previews: PreviewProvider {
    static var previews: some View {
        TxSortSwitch(state: .constant(.all))
    }
}
