//
//  ExchangePicker.swift
//  Portal (macOS)
//
//  Created by Farid on 11.10.2021.
//

import SwiftUI

struct ExchangePicker: View {
    @Binding var state: ExchangeSelectorState
    let exchanges: [ExchangeModel]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(height: 32)
            
            HStack {
                switch state {
                case .merged:
                    Image("iconAllExchangesMerged")
                    Text("All exchanges merged")
                case .selected(let exchange):
                    CoinImageView(size: 12, url: exchange.icon)
                    Text(exchange.name)
                }
                Spacer()
                if exchanges.count > 1 {
                    Image("optionArrowDown")
                }
            }
            .font(.mainFont(size: 12, bold: false))
            .foregroundColor(.gray)
            .padding(.leading, 10)
            .padding(.trailing, 16)
            
            if exchanges.count > 1 {
                MenuButton(
                    label: EmptyView(),
                    content: {
                        Button("All exchange merged") {
                            state = .merged
                        }
                        ForEach(exchanges, id: \.id) { exchange in
                            Button("\(exchange.name)") {
                                state = .selected(exchange: exchange)
                            }
                        }
                    }
                )
                .menuButtonStyle(BorderlessButtonMenuButtonStyle())
            }
        }
    }
}

struct ExchangePicker_Previews: PreviewProvider {
    static var previews: some View {
        ExchangePicker(state: .constant(.merged), exchanges: [])
    }
}
