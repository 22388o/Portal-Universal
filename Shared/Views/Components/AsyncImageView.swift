//
//  AsyncImageView.swift
//  Portal
//
//  Created by Farid on 02.08.2021.
//

import Foundation
import SwiftUI
import Kingfisher

struct AsyncImageViewModel {
    let width: CGFloat
    let height: CGFloat
    let imageUrl: URL?
    
    init(width: CGFloat, height: CGFloat, url: String) {
        self.width = width
        self.height = height
                
        let formattedString = url.replacingOccurrences(of: "http//", with: "https//")
        self.imageUrl = URL(string: formattedString)
    }
}

struct AsyncImageView<Content: View>: View {
    private let placeholder: Content
    private let viewModel: AsyncImageViewModel
 
    init(width: CGFloat, height: CGFloat, url: String, @ViewBuilder placeholder: () -> Content) {
        self.viewModel = AsyncImageViewModel(width: width, height: height, url: url)
        self.placeholder = placeholder()
    }
    
    var body: some View {
        if let imageUrl = viewModel.imageUrl {
            KFImage(imageUrl)
                .cacheOriginalImage()
                .resizable()
                .placeholder {
                    placeholder
                }
        } else {
            placeholder
        }
    }
}
