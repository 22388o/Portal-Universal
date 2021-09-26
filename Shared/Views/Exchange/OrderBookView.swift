//
//  OrderBookView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

class OrderBookViewModel: ObservableObject {
    @Published private var asks: [SocketOrderBookItem] = []
    @Published private var bids: [SocketOrderBookItem] = []

    init(orderBook: SocketOrderBook, tradingPair: TradingPairModel) {
        
    }
}

struct OrderBookView: View {
    let orderBook: SocketOrderBook
    let tradingPair: TradingPairModel

    @State private var route: OrderBookRoute = .buy
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(Color.exchangeBorderColor)
                .frame(width: 1)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Order book")
                        .font(.mainFont(size: 15, bold: false))
                        .foregroundColor(Color.gray)
                        .padding(.leading, 32)
                    Spacer()
                }
                .padding(.top, 25)
                .padding(.bottom, 12)
                
                HStack(spacing: 0) {
                    OrderBookRouteSwitch(route: $route)
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
                    HStack {
                        CoinImageView(size: 16, url: tradingPair.quote_icon)
                        Text("Total")
                    }
                }
                .font(.mainFont(size: 12))
                .foregroundColor(Color.gray)
                .frame(height: 26)
                .padding(.horizontal, 32)
                
                Rectangle()
                    .foregroundColor(Color.exchangeBorderColor)
                    .frame(height: 1)
                
                ScrollView {
                    LazyVStack_(spacing: 0) {
                        switch route {
                        case .buy:
                            ForEach(orderBook.bids, id:\.id) { item in
                                OrderBookItemView(item: item)
                            }
                        case .sell:
                            ForEach(orderBook.asks, id:\.id) { item in
                                OrderBookItemView(item: item)
                            }
                        }
                    }
                }
                
                Rectangle()
                    .foregroundColor(Color.exchangeBorderColor)
                    .frame(height: 1)
            }
        }
    }
}

struct OrderBookView_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookView(orderBook: SocketOrderBook(tradingPair: TradingPairModel.mltBtc(), data: NSDictionary()), tradingPair: TradingPairModel.mltBtc())
    }
}
