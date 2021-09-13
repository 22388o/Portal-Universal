//
//  WalletNameInputView.swift
//  Portal
//
//  Created by Farid on 05.04.2021.
//

import SwiftUI

struct WalletNameInputView: View {
    @Binding var name: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.exchangerFieldBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.exchangerFieldBorder, lineWidth: 1)
                )
            HStack {
                Image("iconSafeSmall")
                ZStack(alignment: .leading) {
                    if name.isEmpty {
                        Text("Enter wallet name")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightActiveLabel.opacity(0.4))
                    }
                    TextField(String(), text: $name)
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightActiveLabel)
                        .colorMultiply(.lightInactiveLabel)
                        .textFieldStyle(PlainTextFieldStyle())
                }
            }
            .padding(.horizontal)
        }
        .frame(width: 267, height: 48)
    }
}

struct WalletNameInputView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WalletNameInputView(name: .constant(String()))
            WalletNameInputView(name: .constant("Personal"))
        }
        .frame(width: 267, height: 48)
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
    }
}
