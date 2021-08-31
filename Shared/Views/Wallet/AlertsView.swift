//
//  AlertsView.swift
//  Portal
//
//  Created by Farid on 03.05.2021.
//

import SwiftUI

struct AlertsView: View {
    let coin: Coin
    @Binding var createAlert: Bool
    
    var body: some View {
        VStack {
            VStack {
                Image("bellIcon")
                    .resizable()
                    .frame(width: 30, height:36)
                Text("Recent changes in \(coin.code)")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.coinViewRouteButtonInactive)
            }
            .padding(.top, 35)
            Spacer()
//            PButton(label: "Manage alerts", width: 256, height: 32, fontSize: 12, enabled: true) {
//                withAnimation {
//                    createAlert.toggle()
//                }
//            }
//            .padding(.bottom, 41)
        }
    }
}

struct AlertsView_Previews: PreviewProvider {
    static var previews: some View {
        AlertsView(coin: Coin.bitcoin(), createAlert: .constant(false))
            .frame(width: 304, height: 480)
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
