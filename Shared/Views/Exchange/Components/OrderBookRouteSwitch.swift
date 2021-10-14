//
//  OrderBookRouteSwitch.swift
//  Portal
//
//  Created by Farid on 30.08.2021.
//

import SwiftUI
import Combine

struct OrderBookRouteSwitch: View {
    @Binding var route: OrderBookRoute
    @State private var alignment: Alignment = .leading
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 2) {
                Button(action: {
                    route = .buy
                }) {
                    Text("Buying")
                        .foregroundColor(route == .buy ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                }
                .frame(width: 38)

                Spacer()
                
                Button(action: {
                    route = .sell
                }) {
                    Text("Selling")
                        .foregroundColor(route == .sell ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                }
                .frame(width: 38)
            }
            .buttonStyle(BorderlessButtonStyle())
            .font(Font.mainFont(size: 12))
            .padding(.vertical, 12)
            
            ZStack(alignment: alignment) {
                Rectangle()
                    .fill(Color.exchangerFieldBorder)
                    .frame(height: 1)
                Divider().background(Color.gray).frame(width: 38, height: 2)
            }
        }
        .onReceive(Just(route), perform: { route in
            switch route {
            case .buy:
                alignment = .leading
            case .sell:
                alignment = .trailing
            }
        })
    }
}

struct OrderBookSwitch_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookRouteSwitch(route: .constant(.buy))
            .frame(width: 87, height: 48)
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
