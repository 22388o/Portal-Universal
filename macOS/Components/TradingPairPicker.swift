//
//  TradingPairPicker.swift
//  Portal (macOS)
//
//  Created by Farid on 11.10.2021.
//

import SwiftUI

struct TradingPairPicker: View {
    @Binding var selectedPair: TradingPairModel?
    let traidingPairs: [TradingPairModel]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(height: 32)
            
            HStack {
                if let tradingPair = selectedPair {
                    CoinImageView(size: 12, url: tradingPair.quote_icon)
                    Text(tradingPair.quote)
                    Spacer()
                    if traidingPairs.filter{ selectedPair?.base == $0.base }.count > 1 {
                        Image("optionArrowDown")
                    }
                }
            }
            .font(.mainFont(size: 12, bold: false))
            .foregroundColor(.gray)
            .padding(.leading, 10)
            .padding(.trailing, 16)
            
            if traidingPairs.filter{ selectedPair?.base == $0.base }.count > 1 {
                MenuButton(
                    label: EmptyView(),
                    content: {
                        ForEach(traidingPairs.filter{ selectedPair?.base == $0.base }.sorted(by: {$1.symbol > $0.symbol}), id: \.id) { tradingPair in
                            Button("\(tradingPair.quote)") {
                                selectedPair = tradingPair
                            }
                        }
                    }
                )
                .menuButtonStyle(BorderlessButtonMenuButtonStyle())
            }
        }
    }
}

struct TradingPairPicker_Previews: PreviewProvider {
    static var previews: some View {
        TradingPairPicker(selectedPair: .constant(TradingPairModel.mltBtc()), traidingPairs: [])
    }
}
