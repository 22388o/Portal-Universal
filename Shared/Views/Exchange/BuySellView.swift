//
//  BuySellView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct BuySellView: View {
    let type: ExchangeButtonType
    let tradingPair: TradingPairModel
    let ticker: SocketTicker
    let title: String
    
    @State var price: String = String()
    
    init(type: ExchangeButtonType, tradingPair: TradingPairModel, ticker: SocketTicker) {
        self.type = type
        self.tradingPair = tradingPair
        self.ticker = ticker
        
        switch type {
        case .buy:
            title = "Buy " + tradingPair.base
        case .sell:
            title = "Sell " + tradingPair.base
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
                        TextField(String(), text: .constant(""))
                            .foregroundColor(Color.lightActiveLabel)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: true,
                                    placeholder: "0"
                                )
                            )
                            .frame(height: 20)
                            .keyboardType(.numberPad)
                        #else
                        TextField(String(), text: .constant(""))
                            .colorMultiply(.lightInactiveLabel)
                            .foregroundColor(Color.lightActiveLabel)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: true,
                                    placeholder: "0",
                                    padding: 0
                                )
                            )
                            .textFieldStyle(PlainTextFieldStyle())
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
                        TextField(String(), text: .constant(String()))
                            .foregroundColor(Color.lightActiveLabel)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: true,
                                    placeholder: "0"
                                )
                            )
                            .frame(height: 20)
                            .keyboardType(.numberPad)
                        #else
                        TextField(String(), text: .constant(ticker.last))
                            .colorMultiply(.lightInactiveLabel)
                            .foregroundColor(Color.lightActiveLabel)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: ticker.last.isEmpty,
                                    placeholder: "0",
                                    padding: 0
                                )
                            )
                            .textFieldStyle(PlainTextFieldStyle())
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
            
            MarketLimitSwitch(state: .constant(.market))
                .padding(.bottom, 16)
            
            BuySellButton(title: title, type: type, enabled: true) {
                
            }
        }
        .padding(.vertical)
    }
}

struct BuySellView_Previews: PreviewProvider {
    static var previews: some View {
        BuySellView(type: .buy, tradingPair: TradingPairModel.mltBtc(), ticker: SocketTicker.init(data: nil, base: nil, quote: nil))
            .padding()
            .background(Color.white)
    }
}
