//
//  SendAssetView.swift
//  Portal
//
//  Created by Farid on 12.04.2021.
//

import SwiftUI

struct SendAssetView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .frame(width: 576, height: 662)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.4), lineWidth: 8)
            )
            .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 2)
    }
}

struct SendAssetView_Previews: PreviewProvider {
    static var previews: some View {
        SendAssetView()
    }
}
