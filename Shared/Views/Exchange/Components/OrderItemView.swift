//
//  OrderItemView.swift
//  Portal
//
//  Created by Farid on 05.10.2021.
//

import SwiftUI

struct OrderItemView: View {
    private let order: ExchangeOrderModel
    private let price: String
    private let amount: String
    private let timestamp: String
    
    init(order: ExchangeOrderModel) {
        self.order = order
        
        let price = Double(order.price) ?? 0.0
        let amount = Double(order.amount) ?? 0.0
        
        var format = "%.5f"
        if price > 10 {
            format = "%.2f"
        }
        
        self.price = String(format: format, price)
        
        format = "%.5f"
        if amount > 10 {
            format = "%.2f"
        }
        
        self.amount = String(format: format, amount)
        
        timestamp = StringFormatter.format(timestamp: order.timestamp, shortFormat: true)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.exchangeBorderColor)
                .offset(y: -1)
            
            HStack(spacing: 0) {
                Text(price)
                Spacer()
                Text(amount)
                Spacer()
                Text(timestamp)
            }
            .lineLimit(1)
            .font(.mainFont(size: 12))
            .foregroundColor(Color(red: 7.0/255.0, green: 191.0/255.0, blue: 104.0/255.0).opacity(0.94))
            .frame(height: 32)
            .padding(.horizontal, 32)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.exchangeBorderColor)
                .onTapGesture {
                    print("Cancel")
                }
        }
    }
}

struct OrderItemView_Previews: PreviewProvider {
    static var previews: some View {
        OrderItemView(order: ExchangeOrderModel.init(
                        order: BinanceOrder(
                            symbol: "BTCUSD",
                            orderId: 32176532,
                            clientOrderId: "SADSA",
                            price: "0.15",
                            origQty: "1",
                            executedQty: "0",
                            status: "Not filled",
                            timeInForce: "",
                            type: "",
                            side: "",
                            stopPrice: "",
                            icebergQty: "",
                            time: 123123,
                            isWorking: true
                        )
        ))
    }
}
