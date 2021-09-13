//
//  AccountItemView.swift
//  Portal
//
//  Created by Farid on 26.04.2021.
//

import SwiftUI

struct AccountItemView: View {
    let name: String
    let selected: Bool
    let onDelete: ()->()
    
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
                
                HStack(spacing: 0) {
                    Text(name)
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                        .padding(.vertical)
                        .padding(.leading, 24)
                    if selected {
                        Spacer()
                        Button(action: {
                            onDelete()
                        }) {
                            Image("trash")
                                .resizable()
                                .frame(width: 18, height: 18)
                        }
                        .foregroundColor(.red)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.trailing, 12)

                Divider()
                    .background(Color.black.opacity(0.09))
                    .offset(y: 1)
            }
        }
        .background(selected ? Color.black.opacity(0.04) : Color.white.opacity(0.94))
    }
}

struct AccountItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AccountItemView(name: "Personal", selected: true, onDelete: {})
                .frame(width: 216, height: 48)
                .padding()
                .previewLayout(PreviewLayout.sizeThatFits)
            AccountItemView(name: "Buisness", selected: false, onDelete: {})
                .frame(width: 216, height: 48)
                .padding()
                .previewLayout(PreviewLayout.sizeThatFits)
        }
    }
}
