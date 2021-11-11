//
//  EthNetworkPicker.swift
//  Portal (iOS)
//
//  Created by Farid on 03.11.2021.
//

import SwiftUI
import EthereumKit

struct EthNetworkPicker: View {
    @Binding var ethNetwork: EthereumKit.NetworkType
    let description: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundColor(Color.black.opacity(0.05))
            .overlay(
                Menu {
                    Button("mainNet") {
                        ethNetwork = .ethMainNet
                    }
                    Button("ropsten") {
                        ethNetwork = .ropsten
                    }
                    Button("kovan") {
                        ethNetwork = .kovan
                    }
                } label: {
                    HStack {
                        Text(description)
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.lightActiveLabel)
                        Spacer()
                        Image("optionArrowDownDark")
                    }
                    .padding(.horizontal, 6)
                    .offset(x: 25)
                }
                .offset(x: -25)
            )
    }
}
