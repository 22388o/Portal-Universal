//
//  RestoreSeedField.swift
//  Portal
//
//  Created by Farid on 09.05.2021.
//

import SwiftUI

struct RestoreSeedField: View {
    @Binding var text: String
    
    let index: Int
    let placeholder: String = "enter word"
    let upperCase: Bool = false

    let width: CGFloat = 176
    let height: CGFloat = 32
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height/2, style: .continuous)
                .fill(Color.exchangerFieldBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: height/2)
                        .stroke(Color.exchangerFieldBorder, lineWidth: 1)
                )
            HStack(spacing: 0) {
                Text("\(index)")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.lightActiveLabel)
                    .frame(width: 48)
                
                Rectangle()
                    .foregroundColor(Color.exchangerFieldBorder)
                    .frame(width: 1, height: 24)
                
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
                        .padding(.trailing, 8)
                    #else
                    TextField(String(), text: $text)
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightActiveLabel)
                        .padding(.trailing, 8)
                        .textFieldStyle(PlainTextFieldStyle())
                    #endif
                }
                .padding(.leading, 15)
            }
        }
        .frame(width: width, height: height)
    }
}

struct RestoreSeedField_Previews: PreviewProvider {
    static var previews: some View {
        RestoreSeedField(text: .constant(""), index: 5)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
