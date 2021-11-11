//
//  MyOrdersView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct MyOrdersView: View {
    private let tradingPair: TradingPairModel
    private let orders: [ExchangeOrderModel]
    private let onOrderCancel: (_ order: ExchangeOrderModel) -> Void
    
    @State private var route: MyOrdersRoute = .open
    
    init(tradingPair: TradingPairModel, orders: [ExchangeOrderModel], onOrderCancel: @escaping (_ order: ExchangeOrderModel) -> Void) {
        self.tradingPair = tradingPair
        self.orders = orders
        self.onOrderCancel = onOrderCancel
    }
    
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
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 25)
                .padding(.bottom, 12)
                
                HStack(spacing: 0) {
                    MyOrdersRouteSwitch(route: $route)
                        .frame(width: 90)
                        .padding(.leading, 20)
                    Spacer()
                }
                
                Rectangle()
                    .foregroundColor(Color.exchangeBorderColor)
                    .frame(height: 1)

                HStack {
                    Text("Side")
                    Spacer()
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
                    
                    Spacer()
                    
                    Text("Status")
                }
                .font(.mainFont(size: 12))
                .foregroundColor(Color.gray)
                .frame(height: 26)
                .padding(.horizontal, 20)
                
                Rectangle()
                    .foregroundColor(Color.exchangeBorderColor)
                    .frame(height: 1)
                                
                ScrollView {
                    LazyVStack_(spacing: 0) {
                        switch route {
                        case .open:
                            ForEach(orders.filter{ $0.status == "open"}, id:\.id) { order in
                                OrderItemView(order: order, isOpen: true, onCancel: {
                                    onOrderCancel(order)
                                })
                                .id(order.id)
                            }
                        case .history:
                            ForEach(orders.filter{ $0.status == "closed" || $0.status == "FILLED" || $0.status == "CANCELED"}, id:\.id) { order in
                                OrderItemView(order: order, isOpen: false, onCancel: {})
                                    .id(order.id)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct MyOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        MyOrdersView(tradingPair: TradingPairModel.mltBtc(), orders: [], onOrderCancel: { _ in })
    }
}
