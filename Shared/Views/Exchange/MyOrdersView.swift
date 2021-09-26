//
//  MyOrdersView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct MyOrdersView: View {
    let tradingPair: TradingPairModel
    
    @State private var route: MyOrdersRoute = .open
    @State private var items = [
        SocketOrderBookItem(price: 10.15, amount: 2),
        SocketOrderBookItem(price: 0.1233, amount: 200),
        SocketOrderBookItem(price: 15.16, amount: 35)
    ]
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(Color.exchangeBorderColor)
                .frame(width: 1)
            
            VStack(spacing: 0) {
                HStack {
                    Text("My orders")
                        .font(.mainFont(size: 15, bold: false))
                        .foregroundColor(Color.gray)
                        .padding(.leading, 32)
                    Spacer()
                }
                .padding(.top, 25)
                .padding(.bottom, 12)
                
                HStack(spacing: 0) {
                    MyOrdersRouteSwitch(route: $route)
                        .frame(width: 87)
                        .padding(.leading, 32)
                    Spacer()
                }
                
                Rectangle()
                    .foregroundColor(Color.exchangeBorderColor)
                    .frame(height: 1)

                HStack {
                    HStack {
                        CoinImageView(size: 16, url: tradingPair.quote_icon)
                        Text("Price")
                    }
                    Spacer()
                    HStack {
                        CoinImageView(size: 16, url: tradingPair.icon)
                        Text("Amount")
                    }
                    Spacer()
                    
                    Text("Time")
                }
                .font(.mainFont(size: 12))
                .foregroundColor(Color.gray)
                .frame(height: 26)
                .padding(.horizontal, 32)
                
                Rectangle()
                    .foregroundColor(Color.exchangeBorderColor)
                    .frame(height: 1)
                
                Spacer()
                
//                ScrollView {
//                    LazyVStack_(spacing: 0) {
//                        ForEach(items, id:\.id) { item in
//                            OrderBookItemView(item: item)
//                        }
//                    }
//                }
            }
        }
    }
}

struct MyOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        MyOrdersView(tradingPair: TradingPairModel.mltBtc())
    }
}
