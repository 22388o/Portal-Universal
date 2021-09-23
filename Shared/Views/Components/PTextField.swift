//
//  PTextField.swift
//  Portal
//
//  Created by Farid on 06.04.2021.
//

import SwiftUI

struct PTextField: View {
    @Binding var text: String
    
    let placeholder: String
    let upperCase: Bool

    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height/2, style: .continuous)
                .fill(Color.exchangerFieldBackground)
                .frame(width: width, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: height/2)
                        .stroke(Color.exchangerFieldBorder, lineWidth: 1)
                )
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightActiveLabel.opacity(0.4))
                }
                #if os(iOS)
                TextField(String(), text: $text)
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.lightActiveLabel)
                    .autocapitalization(upperCase ? .sentences : .none)
                    .disableAutocorrection(true)
                #else
                TextField(String(), text: $text)
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.lightActiveLabel)
                    .colorMultiply(.lightInactiveLabel)
                    .disableAutocorrection(true)
                    .textFieldStyle(PlainTextFieldStyle())
                #endif
            }
            .padding(.horizontal, 24)
        }
        .frame(width: width, height: height)
    }
}

struct PTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PTextField(text: .constant("Car"), placeholder: "Enter word", upperCase: false, width: 192, height: 48)
            PTextField(text: .constant(String()), placeholder: "Enter word", upperCase: false, width: 300, height: 48)
        }
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
    }
}
