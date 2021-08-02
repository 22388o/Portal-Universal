//
//  CoinImageView.swift
//  Portal
//
//  Created by Farid on 02.08.2021.
//

import SwiftUI

struct CoinImageView: View {
    let size: CGFloat
    let url: String
    var placeholderForegroundColor: Color? = nil
    
    var body: some View {
        if let color = placeholderForegroundColor {
            AsyncImageView(width: size, height: size, url: url) {
                Image(systemName: "dollarsign.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(color)
                    .frame(width: size, height: size)
            }
            .frame(width: size, height: size)
            .cornerRadius(size/2)
        } else {
            AsyncImageView(width: size, height: size, url: url) {
                Image(systemName: "dollarsign.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
            .frame(width: size, height: size)
            .cornerRadius(size/2)
        }
    }
}
