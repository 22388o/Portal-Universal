//
//  BtcNetworkPicker.swift
//  Portal (iOS)
//
//  Created by Farid on 03.11.2021.
//

import SwiftUI
import BitcoinKit

struct BtcNetworkPicker: View {
    @Binding var btcNetwork: Kit.NetworkType
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundColor(Color.black.opacity(0.05))
            .overlay(
                Menu {
                    Button("mainNet") {
                        btcNetwork = .mainNet
                    }
                    Button("testNet") {
                        btcNetwork = .testNet
                    }
//                    Button("regTest") {
//                        btcNetwork = .regTest
//                    }
                } label: {
                    HStack {
                        Text(btcNetwork.rawValue)
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
