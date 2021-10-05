//
//  MyOrdersView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct MyOrdersView: View {
    let tradingPair: TradingPairModel
    let orders: [ExchangeOrderModel]
    
    @State private var route: MyOrdersRoute = .open
    
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
                
                ScrollView {
                    LazyVStack_(spacing: 0) {
                        ForEach(orders, id:\.id) { order in
                            OrderItemView(order: order)
                        }
                    }
                }
            }
        }
    }
}

struct MyOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        MyOrdersView(tradingPair: TradingPairModel.mltBtc(), orders: [])
    }
}
