//
//  ExchangeBalanceItem.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import SwiftUI

struct ExchangeBalanceItem: View {
    let balanceItem: ExchangeBalanceModel
    let iconUrl: String?
    let selected: Bool
    
    var body: some View {
        ZStack {
            if selected {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 88/255, green: 106/255, blue: 130/255, opacity: 0.3))
            }
            
            HStack {
                CoinImageView(size: 16, url: iconUrl ?? String())
                
                Text("\(balanceItem.free) \(balanceItem.asset)")
                
                Spacer()
            }
            .font(.mainFont(size: 12, bold: false))
            .foregroundColor(.gray)
            .padding(.horizontal, 8)
        }
        .frame(height: 32)
    }
}

struct ExchangeBalanceItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExchangeBalanceItem(balanceItem: ExchangeBalanceModel.BTC(), iconUrl: nil, selected: true)
            ExchangeBalanceItem(balanceItem: ExchangeBalanceModel.ETH(), iconUrl: nil, selected: false)
        }
    }
}
