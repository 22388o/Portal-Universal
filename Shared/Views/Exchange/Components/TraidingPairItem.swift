//
//  TraidingPairItem.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import SwiftUI

struct TradingPairItem: View {
    let traidingPair: TradingPairModel
    let selected: Bool
    
    var body: some View {
        ZStack {
            if selected {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            }
            
            HStack {
                CoinImageView(size: 16, url: traidingPair.icon)
                
                Text(traidingPair.base)
                
                Spacer()
                
                Text("\(Double(traidingPair.change).rounded(toPlaces: 2).toString())%")
                    .foregroundColor(traidingPair.change > 0 ? .green : .red)
            }
            .font(.mainFont(size: 12, bold: false))
            .foregroundColor(.gray)
            .padding(.horizontal, 8)
        }
        .frame(height: 32)
    }
}

struct TradingPairItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TradingPairItem(traidingPair: TradingPairModel.mltBtc(), selected: true)
            TradingPairItem(traidingPair: TradingPairModel.mltBtc(), selected: false)
        }
    }
}
