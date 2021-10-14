//
//  PairsSearchField.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import SwiftUI

struct PairSearchField: View {
    @Binding var search: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .opacity(0.14)
                .frame(height: 32)
            
            HStack {
                Image("magnifyingglass")
                    .resizable()
                    .frame(width: 11, height: 11)
                    .foregroundColor(Color.gray)
            }
            .padding(.horizontal, 11)
            
            if search.isEmpty {
                Text("Search")
                    .font(.mainFont(size: 12, bold: false))
                    .foregroundColor(Color.gray)
                    .padding(.horizontal, 32)
            }
            TextField(String(), text: $search)
                .foregroundColor(Color.gray)
                .padding(.horizontal, 32)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .font(.mainFont(size: 15))
    }
}

struct PairSearchField_Previews: PreviewProvider {
    static var previews: some View {
        AssetSearchField(search: .constant(String()))
            .frame(width: 256, height: 32)
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
