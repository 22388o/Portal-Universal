//
//  BtcNetworkPicker.swift
//  Portal (macOS)
//
//  Created by Farid on 03.11.2021.
//

import SwiftUI
import BitcoinKit

struct BtcNetworkPicker: View {
    @Binding var btcNetwork: Kit.NetworkType
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(Color.black.opacity(0.05))
            
            HStack {
                Text(btcNetwork.rawValue)
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
                        btcNetwork = .mainNet
                    }
                    Button("testNet") {
                        btcNetwork = .testNet
                    }
                    Button("regTest") {
                        btcNetwork = .regTest
                    }
                }
            )
            .menuButtonStyle(BorderlessButtonMenuButtonStyle())
        }
    }
}
