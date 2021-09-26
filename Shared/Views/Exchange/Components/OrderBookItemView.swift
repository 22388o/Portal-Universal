//
//  OrderBookItemView.swift
//  Portal
//
//  Created by Farid on 30.08.2021.
//

import SwiftUI

struct OrderBookItemView: View {
    let item: SocketOrderBookItem
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.exchangeBorderColor)
                .offset(y: -1)
            
            HStack(spacing: 0) {
                Text(item.price.toString())
                Spacer()
                Text(item.amount.toString())
                Spacer()
                Text(item.total.toString())
            }
            .lineLimit(1)
            .font(.mainFont(size: 12))
            .foregroundColor(Color(red: 7.0/255.0, green: 191.0/255.0, blue: 104.0/255.0).opacity(0.94))
            .frame(height: 32)
            .padding(.horizontal, 32)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.exchangeBorderColor)
        }
    }
}

struct OrderBookItem_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookItemView(item: SocketOrderBookItem(price: 0.000021, amount: 10))
    }
}
