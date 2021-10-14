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
    private let isOpen: Bool
    private let onCancel: () -> Void
    
    @State private var onMouseOver = false
    
    init(order: ExchangeOrderModel, isOpen: Bool, onCancel: @escaping () -> Void) {
        self.order = order
        self.isOpen = isOpen
        self.onCancel = onCancel
        
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
                if onMouseOver {
                    Text("Cancel")
                        .foregroundColor(Color.red)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onCancel()
                        }
                } else {
                    Text(order.side)
                    Spacer()
                    Text(price == "0.00000" ? "MARKET" : price)
                    Spacer()
                    Text(amount)
                    Spacer()
                    Text(timestamp)
                    Spacer()
                    Text(order.status.uppercased())
                        .frame(width: 30)
                        .font(.mainFont(size: 8))
                }
            }
            .lineLimit(1)
            .font(.mainFont(size: 12))
            .foregroundColor(Color(red: 7.0/255.0, green: 191.0/255.0, blue: 104.0/255.0).opacity(0.94))
            .frame(height: 32)
            .padding(.horizontal, 20)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.exchangeBorderColor)
                .onTapGesture {
                    print("Cancel")
                }
        }
        .contentShape(Rectangle())
        .onHover { over in
            if isOpen {
                onMouseOver = over
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
        ), isOpen: true, onCancel: {})
    }
}
