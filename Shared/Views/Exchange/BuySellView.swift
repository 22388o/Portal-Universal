//
//  BuySellView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct BuySellView: View {
    typealias OnOrderCreateCompetion = (_ type: OrderType, _ side: OrderSide, _ price: String, _ amount: String) -> ()
    
    let orderSide: OrderSide
    let exchange: ExchangeModel?
    let tradingPair: TradingPairModel
    let ticker: SocketTicker
    let title: String
    let canTrade: Bool
    let onOrderCreate: OnOrderCreateCompetion
    
    @State var price = String()
    @State var amount = String()
    @State var orderType: OrderType = .market
    
    init(
        side: OrderSide,
        exchange: ExchangeModel?,
        tradingPair: TradingPairModel,
        ticker: SocketTicker,
        onOrderCreate: @escaping OnOrderCreateCompetion
    ) {
        self.orderSide = side
        self.exchange = exchange
        self.tradingPair = tradingPair
        self.ticker = ticker
        self.onOrderCreate = onOrderCreate
        
        switch orderSide {
        case .buy:
            title = "Buy " + tradingPair.base
            
            if ((exchange?.balances.filter({ $0.asset == tradingPair.quote }).first) != nil) {
                canTrade = true
            } else {
                canTrade = false
            }
        case .sell:
            title = "Sell " + tradingPair.base
            
            if ((exchange?.balances.filter({ $0.asset == tradingPair.base }).first) != nil) {
                canTrade = true
            } else {
                canTrade = false
            }
        }

        price = ticker.last
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                Spacer()
            }
            .font(.mainFont(size: 15, bold: false))
            .foregroundColor(Color.gray)
            .padding(.bottom, 14)
            
            HStack(spacing: 16) {
                VStack(spacing: 5) {
                    HStack {
                        Text("Amount")
                            .font(.mainFont(size: 12, bold: false))
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        CoinImageView(size: 24, url: tradingPair.icon)
                            .padding(8)

                        #if os(iOS)
                        TextField(String(), text: $amount)
                            .foregroundColor(Color.lightActiveLabel)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: true,
                                    placeholder: "0"
                                )
                            )
                            .frame(height: 20)
                            .keyboardType(.numberPad)
                            .disabled(!canTrade)
                        #else
                        TextField(String(), text: $amount)
                            .colorMultiply(.lightInactiveLabel)
                            .foregroundColor(Color.lightActiveLabel)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: amount.isEmpty,
                                    placeholder: "0",
                                    padding: 0
                                )
                            )
                            .textFieldStyle(PlainTextFieldStyle())
                            .disabled(!canTrade)
                        #endif
                    }
                    .modifier(SmallTextFieldModifier(cornerRadius: 16))
                }
                VStack(spacing: 5) {
                    HStack {
                        Text("Price")
                            .font(.mainFont(size: 12, bold: false))
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        CoinImageView(size: 24, url: tradingPair.quote_icon)
                            .padding(8)
                        
                        #if os(iOS)
                        TextField(String(), text: $price)
                            .foregroundColor(Color.lightActiveLabel)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: price.isEmpty,
                                    placeholder: orderType == .market ? "\(ticker.last)" : "0"
                                )
                            )
                            .frame(height: 20)
                            .keyboardType(.numberPad)
                            .disabled(orderType == .market)
                        #else
                        TextField(String(), text: $price)
                            .colorMultiply(.lightInactiveLabel)
                            .foregroundColor(Color.lightActiveLabel)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: price.isEmpty,
                                    placeholder: orderType == .market ? "\(ticker.last)" : "0",
                                    padding: 0
                                )
                            )
                            .textFieldStyle(PlainTextFieldStyle())
                            .disabled(orderType == .market)
                        #endif
                    }
                    .modifier(SmallTextFieldModifier(cornerRadius: 16))
                }
            }
            
            HStack {
                Text("Type")
                    .font(.mainFont(size: 12, bold: false))
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding(.top, 14)
            .padding(.bottom, 6)
            
            MarketLimitSwitch(state: $orderType)
                .padding(.bottom, 16)
                .disabled(!canTrade)
            
            BuySellButton(title: title, side: orderSide, enabled: canTrade) {
                onOrderCreate(orderType, orderSide, amount, price)
                amount = String()
                price = String()
            }
        }
        .padding(.vertical)
    }
}

struct BuySellView_Previews: PreviewProvider {
    static var previews: some View {
        BuySellView(
            side: .buy,
            exchange: ExchangeModel.binanceMock(),
            tradingPair: TradingPairModel.mltBtc(),
            ticker: SocketTicker.init(data: nil, base: nil, quote: nil),
            onOrderCreate: { type, side, price, amount in
                
            }
        )
        .padding()
        .background(Color.white)
    }
}
