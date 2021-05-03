//
//  AssetSearchField.swift
//  Portal
//
//  Created by Farid on 10.04.2021.
//

import SwiftUI

struct AssetSearchField: View {
    @Binding var search: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.94))
                .opacity(0.14)
                .frame(height: 40)
            
            if search.isEmpty {
                Text("Find asset...")
                    .font(.mainFont(size: 15))
                    .foregroundColor(Color.white.opacity(0.8))
                    .padding(.horizontal, 21)
            }
            TextField(String(), text: $search)
                .font(.mainFont(size: 15))
                .foregroundColor(Color.white.opacity(0.5))
                .padding(.horizontal, 21)
        }
    }
}

struct AssetSearchField_Previews: PreviewProvider {
    static var previews: some View {
        AssetSearchField(search: .constant(String()))
            .frame(width: 379, height: 40)
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
