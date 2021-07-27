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
            ZStack {
                RoundedRectangle(cornerRadius: height/2, style: .continuous)
                    .fill(enabled ? bgColor! : Color.pButtonDisableBackground)
                    .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                Text(label)
                    .font(.mainFont(size: fontSize))
                    .foregroundColor(.white)
            }
        }
        .frame(width: width, height: height)
        .disabled(!enabled)
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
