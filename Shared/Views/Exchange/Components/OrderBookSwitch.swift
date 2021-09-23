//
//  OrderBookSwitch.swift
//  Portal
//
//  Created by Farid on 30.08.2021.
//

import SwiftUI
import Combine

struct OrderBookSwitch: View {
    @Binding var route: OrderBookRoute
    @State private var alignment: Alignment = .leading
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 2) {
                Button(action: {
                    route = .buying
                }) {
                    Text("Buying")
                        .foregroundColor(route == .buying ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                }
                .frame(width: 38)

                Spacer()
                
                Button(action: {
                    route = .selling
                }) {
                    Text("Selling")
                        .foregroundColor(route == .selling ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
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
            case .buying:
                alignment = .leading
            case .selling:
                alignment = .trailing
            }
        })
    }
}

struct OrderBookSwitch_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookSwitch(route: .constant(.buying))
            .frame(width: 87, height: 48)
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
