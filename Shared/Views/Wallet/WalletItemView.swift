//
//  WalletItemView.swift
//  Portal
//
//  Created by Farid on 26.04.2021.
//

import SwiftUI

struct WalletItemView: View {
    let name: String
    let selected: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if selected {
                RoundedRectangle(cornerRadius: 2)
                    .foregroundColor(Color.selectedWallet)
                    .frame(width: 4, height: 36)
                    .padding(.leading, 12)
            }
                
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                    .background(Color.black.opacity(0.09))
                Text(name)
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.coinViewRouteButtonActive)
                    .padding(.vertical)
                    .padding(.leading, 24)
                Divider()
                    .background(Color.black.opacity(0.09))
            }
        }
        .background(selected ? Color.black.opacity(0.04) : Color.white.opacity(0.94))
    }
}

struct WalletItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WalletItemView(name: "Personal", selected: true)
                .frame(width: 216, height: 48)
                .padding()
                .previewLayout(PreviewLayout.sizeThatFits)
            WalletItemView(name: "Buisness", selected: false)
                .frame(width: 216, height: 48)
                .padding()
                .previewLayout(PreviewLayout.sizeThatFits)
        }
    }
}
