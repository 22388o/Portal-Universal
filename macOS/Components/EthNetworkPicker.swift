//
//  EthNetworkPicker.swift
//  Portal (macOS)
//
//  Created by Farid on 03.11.2021.
//

import SwiftUI
import EthereumKit

struct EthNetworkPicker: View {
    @Binding var ethNetwork: EthereumKit.NetworkType
    let description: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(Color.black.opacity(0.05))
            
            HStack {
                Text(description)
                    .font(.mainFont(size: 12))
                    .foregroundColor(Color.lightActiveLabel)
                Spacer()
                Image("optionArrowDownDark")
            }
            .padding(.horizontal, 6)
            
            MenuButton(
                label: EmptyView(),
                content: {
                    Button("mainNet") {
                        ethNetwork = .ethMainNet
                    }
                    Button("ropsten") {
                        ethNetwork = .ropsten
                    }
                    Button("kovan") {
                        ethNetwork = .kovan
                    }
                }
            )
            .menuButtonStyle(BorderlessButtonMenuButtonStyle())
        }
    }
}
