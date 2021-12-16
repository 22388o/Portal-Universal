//
//  ExchangeBalanceItem.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import SwiftUI

struct ExchangeBalanceItem: View {
    private let balanceItem: ExchangeBalanceModel
    private let iconUrl: String?
    private let onWithdraw: () -> ()
    
    @State private var onPointerOver = false
    
    init(balanceItem: ExchangeBalanceModel, iconUrl: String?, onWithdraw: @escaping () -> ()) {
        self.balanceItem = balanceItem
        self.iconUrl = iconUrl
        self.onWithdraw = onWithdraw
    }
    
    var body: some View {
        ZStack {
            if onPointerOver {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 88/255, green: 106/255, blue: 130/255, opacity: 0.3))
                
                HStack {
                    Spacer()
                    Text("Withdraw")
                        .font(.mainFont(size: 12, bold: false))
                        .foregroundColor(.gray)
                        .padding(.trailing, 12)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onWithdraw()
                        }
                }
            }
            
            HStack {
                CoinImageView(size: 16, url: iconUrl ?? String())
                
                Text("\(balanceItem.free) \(balanceItem.asset)")
                
                Spacer()
            }
            .font(.mainFont(size: 12, bold: false))
            .foregroundColor(onPointerOver ? .white : .gray)
            .padding(.horizontal, 8)
        }
        .frame(height: 32)
        .onHover { over in
            onPointerOver = over
        }
    }
}

struct ExchangeBalanceItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExchangeBalanceItem(balanceItem: ExchangeBalanceModel.BTC(), iconUrl: nil, onWithdraw: {})
            ExchangeBalanceItem(balanceItem: ExchangeBalanceModel.ETH(), iconUrl: nil, onWithdraw: {})
        }
    }
}
