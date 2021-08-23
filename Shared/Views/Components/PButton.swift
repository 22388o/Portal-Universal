//
//  PButton.swift
//  Portal
//
//  Created by Farid on 05.04.2021.
//

import SwiftUI

struct PButton: View {
    var bgColor: Color? = Color.pButtonEnabledBackground
    let label: String
    let width: CGFloat
    let height: CGFloat
    let fontSize: CGFloat
    let enabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if enabled {
                action()
            }
        }) {
            Text(label)
                .frame(width: width, height: height)
        }
        .buttonStyle(
            PortalButtonStyle(
                fontSize: fontSize,
                foregroundColor: .white,
                backgroundColor: bgColor!,
                pressedColor: bgColor!.opacity(0.5),
                width: width,
                height: height,
                enabled: enabled
            )
        )
        .disabled(!enabled)
    }
}

struct PortalButtonStyle: ButtonStyle {
    let fontSize: CGFloat
    let foregroundColor: Color
    let backgroundColor: Color
    let pressedColor: Color
    let width: CGFloat
    let height: CGFloat
    let enabled: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.mainFont(size: fontSize))
            .foregroundColor(foregroundColor)
            .background(enabled ? configuration.isPressed ? pressedColor : backgroundColor : Color.pButtonDisableBackground)
            .cornerRadius(height/2)
    }
}

struct PButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PButton(label: "Continue", width: 124, height: 48, fontSize: 15, enabled: false, action: {})
            PButton(label: "Continue", width: 124, height: 48, fontSize: 15, enabled: true, action: {})
        }
        .frame(width: 124, height: 48)
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
    }
}
