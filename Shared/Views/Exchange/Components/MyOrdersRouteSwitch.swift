//
//  MyOrdersRouteSwitch.swift
//  Portal
//
//  Created by Farid on 02.09.2021.
//

import SwiftUI
import Combine

struct MyOrdersRouteSwitch: View {
    @Binding var route: MyOrdersRoute
    @State private var alignment: Alignment = .leading
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 2) {
                Button(action: {
                    route = .open
                }) {
                    Text("Open")
                        .foregroundColor(route == .open ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                }
                .frame(width: 38)

                Spacer()
                
                Button(action: {
                    route = .history
                }) {
                    Text("History")
                        .foregroundColor(route == .history ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
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
            case .open:
                alignment = .leading
            case .history:
                alignment = .trailing
            }
        })
    }
}

struct MyOrdersRouteSwitch_Previews: PreviewProvider {
    static var previews: some View {
        MyOrdersRouteSwitch(route: .constant(.open))
            .frame(width: 87, height: 48)
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
