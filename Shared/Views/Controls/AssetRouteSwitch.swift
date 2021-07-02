//
//  AssetRouteSwitch.swift
//  Portal
//
//  Created by Farid on 11.04.2021.
//

import SwiftUI
import Combine

struct AssetRouteSwitch: View {
    @Binding var route: AssetViewRoute
    @State private var alignment: Alignment = .leading
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 2) {
                Button(action: {
                    route = .value
                }) {
                    Text("Value")
                        .foregroundColor(route == .value ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                }
                .frame(width: 75)

                Spacer()
                
                Button(action: {
                    route = .transactions
                }) {
                    Text("Transactions")
                        .foregroundColor(route == .transactions ?  Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                }
                .frame(width: 75)
                
                Spacer()
                
                Button(action: {
                    route = .alerts
                }) {
                    Text("Alerts")
                        .foregroundColor(route == .alerts ? Color.coinViewRouteButtonActive : Color.coinViewRouteButtonInactive)
                }
                .frame(width: 75)
            }
            .font(Font.mainFont(size: 12))
            .padding(.vertical, 12)
            
            ZStack(alignment: alignment) {
                Rectangle()
                    .fill(Color.exchangerFieldBorder)
                    .frame(height: 1)
                Divider().background(Color.gray).frame(width: 75, height: 2)
            }
        }
        .onReceive(Just(route), perform: { route in
            switch route {
            case .value:
                alignment = .leading
            case .transactions:
                alignment = .center
            case .alerts:
                alignment = .trailing
            }
        })
    }
}

struct AssetRouteSwitch_Previews: PreviewProvider {
    static var previews: some View {
        AssetRouteSwitch(route: .constant(.value))
            .frame(width: 290, height: 48)
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
