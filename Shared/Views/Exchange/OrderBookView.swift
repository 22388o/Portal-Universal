//
//  OrderBookView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct OrderBookView: View {
    @State private var route: OrderBookRoute = .buying
    @State private var items = [
        SocketOrderBookItem(price: 10.15, amount: 2),
        SocketOrderBookItem(price: 0.1233, amount: 200),
        SocketOrderBookItem(price: 15.16, amount: 35)
    ]
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(.gray)
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
                    OrderBookSwitch(route: $route)
                        .frame(width: 87)
                        .padding(.leading, 32)
                    Spacer()
                }
                
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(height: 1)

                HStack {
                    Text("Price")
                    Spacer()
                    Text("Amount")
                    Spacer()
                    Text("Total")
                }
                .font(.mainFont(size: 12))
                .foregroundColor(Color.gray)
                .frame(height: 26)
                .padding(.horizontal, 32)
                
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(height: 1)
                
                ScrollView {
                    LazyVStack_(spacing: 0) {
                        ForEach(items, id:\.id) { item in
                            OrderBookItemView()
                        }
                    }
                }
            }
        }
    }
}

struct OrderBookView_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookView()
    }
}
