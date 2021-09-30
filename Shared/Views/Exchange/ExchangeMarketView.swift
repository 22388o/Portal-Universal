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
    let ticker: SocketTicker
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
                .frame(minHeight: 224)
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
            
            HStack(spacing: 50) {
                VStack(alignment: .leading) {
                    Text("Change")
                    Text(ticker.change)
                }
                VStack(alignment: .leading) {
                    Text("Last price")
                    Text(ticker.last)
                }
                VStack(alignment: .leading) {
                    Text("Highest")
                    Text(ticker.high)
                }
                VStack(alignment: .leading) {
                    Text("Lowest")
                    Text(ticker.low)
                }
                VStack(alignment: .leading) {
                    Text("Volume")
                    Text(ticker.volume)
                }
                
                Spacer()
            }
            .font(.mainFont(size: 12, bold: false))
            .foregroundColor(Color.gray)
            .padding(.horizontal, 32)
            .padding(.bottom, 28)
                        
            Rectangle()
                .foregroundColor(Color.exchangeBorderColor)
                .frame(height: 1)
        }
    }
}

struct ExchangeMarketView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeMarketView(
            tradingPair: TradingPairModel.mltBtc(),
            tradingData: TradingData(exchangeSelectorState: .merged, exchanges: [], supportedByExchanges: [], pairs: [], currentPair: TradingPairModel.mltBtc()),
            ticker: SocketTicker(data: nil, base: nil, quote: nil)
        )
    }
}
