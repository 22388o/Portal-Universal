//
//  ExchangeScene.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct ExchangeScene: View {
    @StateObject private var viewModel = ExchangeViewModel.config()
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = String()
    
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
                    
                    ExchangeBalancesView(exchanges: viewModel.syncedExchanges, state: $viewModel.exchangeBalancesSelectorState)
                    
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
                                BuySellView(
                                    side: .buy,
                                    exchange: viewModel.tradingData?.exchange,
                                    tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc(),
                                    ticker: viewModel.currentPairTicker,
                                    onOrderCreate: { type, side, amount, price in
                                        print("amount: \(amount), price: \(price), side: \(side), type: \(type)")
                                        guard !amount.isEmpty else {
                                            errorMessage = "Invalid amount"
                                            showAlert = true
                                            return
                                        }
                                        
                                        if type == .limit, price.isEmpty {
                                            errorMessage = "Invalid amount"
                                            showAlert = true
                                            return
                                        }
                                        viewModel.placeOrder(type: type, side: side, amount: amount, price: price)
                                    }
                                )
                                .frame(minWidth: 256, maxWidth: .infinity)
                                .frame(height: 256)
                                
                                BuySellView(
                                    side: .sell,
                                    exchange: viewModel.tradingData?.exchange,
                                    tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc(),
                                    ticker: viewModel.currentPairTicker,
                                    onOrderCreate: { type, side, amount, price in
                                        print("amount: \(amount), price: \(price), side: \(side), type: \(type)")
                                        guard !amount.isEmpty else {
                                            errorMessage = "Invalid amount"
                                            showAlert = true
                                            return
                                        }
                                        
                                        if type == .limit, price.isEmpty {
                                            errorMessage = "Invalid amount"
                                            showAlert = true
                                            return
                                        }
                                        viewModel.placeOrder(type: type, side: side, amount: amount, price: price)
                                    }
                                )
                                .frame(minWidth: 256, maxWidth: .infinity)
                                .frame(height: 256)
                            }
                            .padding(.horizontal, 32)
                        }

                        VStack(spacing: 0) {
                            OrderBookView(
                                orderBook: viewModel.orderBook ?? SocketOrderBook(tradingPair: TradingPairModel.mltBtc(), data: NSDictionary()),
                                tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc()
                            )
                            .frame(width: 296)
                            .frame(minHeight: 374, maxHeight: .infinity)
                            
                            MyOrdersView(
                                tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc(),
                                orders: viewModel.tradingData?.exchange?.orders.filter{ $0.symbol?.contains(viewModel.currentPair?.base ?? "") ?? false && $0.symbol?.contains(viewModel.currentPair?.quote ?? "") ?? false} ?? []
                            )
                            .frame(width: 296, height: 256)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding([.vertical, .trailing], 8)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Cannot process order"), message: Text(errorMessage), dismissButton: .default(Text("Dismiss"), action: {
                        withAnimation {
                            showAlert.toggle()
                        }
                    }))
                }
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
