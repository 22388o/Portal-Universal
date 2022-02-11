//
//  ModalViewContainer.swift
//  Portal
//
//  Created by farid on 2/5/22.
//

import SwiftUI

struct ModalViewContainer<Content: View>: View {
    let imageUrl: String
    let size: CGSize
    let content: () -> Content
    
    init(imageUrl: String, size: CGSize, @ViewBuilder _ content: @escaping () -> Content) {
        self.imageUrl = imageUrl
        self.size = size
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.modalViewStrokeColor, lineWidth: 8)
                        .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 0)
                )
            
            CoinImageView(size: 64, url: imageUrl, placeholderForegroundColor: .black)
                .background(Color.white)
                .cornerRadius(32)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.modalViewStrokeColor, lineWidth: 4)
                )
                .offset(y: -32)
            
            content()
        }
        .frame(width: size.width, height: size.height)
    }
}

struct ModalViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ModalViewContainer(imageUrl: "", size: CGSize(width: 565, height: 480), {
            EmptyView()
        }).padding(50)
    }
}
