//
//  BuySellButton.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import SwiftUI

struct BuySellButton: View {
    let title: String
    let type: ExchangeButtonType
    let height: CGFloat = 32
    let enabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if enabled {
                action()
            }
        }) {
            Text(title)
                .frame(height: height)
        }
        .buttonStyle(
            BuySellButtonStyle(
                foregroundColor: .white,
                backgroundColor: bgColor,
                pressedColor: bgColor.opacity(0.5),
                height: height,
                enabled: enabled
            )
        )
        .disabled(!enabled)
    }
    
    var bgColor: Color {
        switch type {
        case .buy:
            return Color.exchangeBuyButtonColor
        case .sell:
            return Color.exchangeSellButtonColor
        }
    }
}

struct BuySellButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BuySellButton(title: "Buy BTC", type: .buy, enabled: false, action: {})
            BuySellButton(title: "Sell USDT", type: .sell, enabled: true, action: {})
        }
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .background(Color.white)
    }
}

struct BuySellButtonStyle: ButtonStyle {
    let fontSize: CGFloat = 12
    let foregroundColor: Color
    let backgroundColor: Color
    let pressedColor: Color
    let height: CGFloat
    let enabled: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.mainFont(size: fontSize))
            .foregroundColor(foregroundColor)
            .background(enabled ? configuration.isPressed ? pressedColor : backgroundColor : Color.pButtonDisableBackground)
            .cornerRadius(height/2)
    }
}
