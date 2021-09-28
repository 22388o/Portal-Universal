//
//  ExchangeScene.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct ExchangeScene: View {
    @StateObject private var viewModel = ExchangeViewModel.config()
    
    var body: some View {
        if viewModel.isLoggedIn {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    ExchangeSelectorView(
                        state: $viewModel.exchangeSelectorState,
                        exchanges: viewModel.syncedExchanges
                    )
                    
                    TradingPairView(
                        traidingPairs: viewModel.tradingPairsForSelectedExchange,
                        selectedPair: $viewModel.currentPair,
                        searchRequest: $viewModel.searchRequest
                    )
                    
                    ExchangeBalancesView(exchanges: viewModel.syncedExchanges)
                    
                    Spacer()
                }
                .frame(width: 320)

                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white)

                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ExchangeMarketView(
                                tradingPair: viewModel.currentPair!,
                                tradingData: viewModel.tradingData,
                                ticker: viewModel.currentPairTicker
                            )
                            .frame(minWidth: 606, minHeight: 374)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                            HStack(spacing: 32) {
                                BuySellView(type: .buy, tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc(), ticker: viewModel.currentPairTicker)
                                    .frame(minWidth: 256, maxWidth: .infinity)
                                    .frame(height: 256)
                                BuySellView(type: .sell, tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc(), ticker: viewModel.currentPairTicker)
                                    .frame(minWidth: 256, maxWidth: .infinity)
                                    .frame(height: 256)
                            }
                            .padding(.horizontal, 32)
                        }

                        VStack(spacing: 0) {
                            OrderBookView(orderBook: viewModel.orderBook ?? SocketOrderBook(tradingPair: TradingPairModel.mltBtc(), data: NSDictionary()), tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc())
                                .frame(width: 296)
                                .frame(minHeight: 374, maxHeight: .infinity)
                            MyOrdersView(tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc())
                                .frame(width: 296, height: 256)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding([.vertical, .trailing], 8)
            }
        } else {
            ExchangeSetup(viewModel: viewModel.setup)
        }
    }
}

struct ExchangeScene_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeScene()
    }
}
