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
            
            HStack {
                Image("magnifyingglass")
                    .resizable()
                    .frame(width: 18, height: 18)
            }
            .padding(.horizontal, 21)
            
            if search.isEmpty {
                Text("Find asset...")
                    .padding(.horizontal, 50)
            }
            TextField(String(), text: $search)
                .padding(.horizontal, 50)
                .textFieldStyle(PlainTextFieldStyle())
            
            HStack {
                Spacer()
                
                Text("Manage")
                    .font(.mainFont(size: 14))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 3.0)) {
                            Portal.shared.state.modalView = .manageAssets
                        }
                    }
            }
            .padding(.horizontal, 21)
        }
        .font(.mainFont(size: 15))
        .foregroundColor(Color.white.opacity(0.5))
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
