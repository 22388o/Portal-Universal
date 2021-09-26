//
//  ExchangeSelectorView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct ExchangeSelectorView: View {
    @Binding var state: ExchangeSelectorState
    let exchanges: [ExchangeModel]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Exchange")
                    .font(.mainFont(size: 15, bold: false))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.top, 25)
            .padding(.bottom, 12)
            
            Selector
            
            Rectangle()
                .foregroundColor(Color.white.opacity(0.10))
                .frame(height: 1)
        }
        .padding(.horizontal, 32)
        .frame(height: 101)
    }
    
    private var Selector: some View {
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
        .padding(.bottom, 12)
    }
}

struct ExchangeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExchangeSelectorView(state: .constant(.merged), exchanges: [ExchangeModel.binanceMock(), ExchangeModel.coinbaseMock()])
            ExchangeSelectorView(state: .constant(.selected(exchange: ExchangeModel.binanceMock())), exchanges: [ExchangeModel.binanceMock(), ExchangeModel.coinbaseMock()])
            ExchangeSelectorView(state: .constant(.selected(exchange: ExchangeModel.binanceMock())), exchanges: [ExchangeModel.binanceMock()])
        }
    }
}
