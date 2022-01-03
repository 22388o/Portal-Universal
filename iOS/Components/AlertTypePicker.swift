//
//  AlertTypePicker.swift
//  Portal (iOS)
//
//  Created by farid on 12/10/21.
//

import SwiftUI

struct AlertTypePicker: View {
    let coin: Coin
    @Binding var type: AlertType
        
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.exchangerFieldBorder, lineWidth: 1)
            )
            .overlay(
                Menu {
                    Button("1.0 \(coin.code) is worth more than...") {
                        type = .worthMore(coin)
                    }
                    Button("1.0 \(coin.code) is worth less than...") {
                        type = .worthLess(coin)
                    }
                    Button("Value of \(coin.code) incrases by...") {
                        type = .incrases(coin)
                    }
                    Button("Value of \(coin.code) discrases by...") {
                        type = .discrases(coin)
                    }
                } label: {
                    HStack {
                        Text(type.description)
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Spacer()
                        Image("optionArrowDownDark")
                    }
                }
                .padding()
            )
    }
}

struct AlertTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        AlertTypePicker(coin: .bitcoin(), type: .constant(.worthMore(.bitcoin())))
            .frame(width: 158, height: 40)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .background(
                ZStack {
                    Color.portalWalletBackground
                    Color.black.opacity(0.58)
                }
            )
    }
}


