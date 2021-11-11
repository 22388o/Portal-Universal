//
//  ExchangeMarketView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct ExchangeMarketView: View {
    let tradingPair: TradingPairModel
    let tradingData: TradingData?
    @State var exchnageIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Market \(tradingPair.symbol)")
                Spacer()
                if let td = tradingData {
                    HStack {
                        Image("arrowLeft")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .opacity(td.supportedByExchanges.count > 1 && td.exchangesMerged ? 1 : 0)
                            .onTapGesture {
                                if exchnageIndex == 0 {
                                    exchnageIndex = td.exchanges.count - 1
                                } else {
                                    exchnageIndex -= 1
                                }
                            }
                        Text(td.exchangesMerged ? "\(td.exchanges[exchnageIndex].name)" : "\(td.exchange?.name ?? "")")
                        Image("arrowRight")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .opacity(td.supportedByExchanges.count > 1 && td.exchangesMerged ? 1 : 0)
                            .onTapGesture {
                                if exchnageIndex == td.exchanges.count - 1 {
                                    exchnageIndex = 0
                                } else {
                                    exchnageIndex += 1
                                }
                            }
                    }
                }
            }
            .font(.mainFont(size: 15, bold: false))
            .foregroundColor(Color.gray)
            .padding(.top, 25)
            .padding(.bottom, 12)
            .padding(.horizontal, 32)
            
            WebView(symbol: tradingPair.exchanger(tradingData?.exchange?.id.lowercased() ?? "")?.sym ?? "")
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
        }
    }
}

struct ExchangeMarketView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeMarketView(
            tradingPair: TradingPairModel.mltBtc(),
            tradingData: TradingData(exchangeSelectorState: .merged, exchanges: [], supportedByExchanges: [], pairs: [], currentPair: TradingPairModel.mltBtc())
        )
    }
}
