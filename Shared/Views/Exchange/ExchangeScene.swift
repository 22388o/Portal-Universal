//
//  ExchangeScene.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct ExchangeScene: View {
    @ObservedObject var state: PortalState
    @ObservedObject var viewModel: ExchangeViewModel
    
    private var paddingForState: Edge.Set {
        switch viewModel.state.exchangeSceneState {
        case .full:
            return [.vertical, .trailing]
        case .compactLeft:
            return .all
        case .compactRight:
            return [.vertical, .trailing]
        }
    }
    
    private var leftPanelWidth: CGFloat {
        #if os(iOS)
        switch state.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown:
            return 210
        default:
            return 320
        }
        #else
        return 320
        #endif
    }
    
    private var rigthPanelWidth: CGFloat {
        #if os(iOS)
        switch state.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown:
            return 210
        default:
            return 350
        }
        #else
        return 350
        #endif
    }
    
    private var marketViewWidth: CGFloat {
        #if os(iOS)
        switch state.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown:
            return 400
        default:
            return 606
        }
        #else
        return 606
        #endif
    }
    
    private var buySellViewWidth: CGFloat {
        #if os(iOS)
        switch state.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown:
            return 205
        default:
            return 256
        }
        #else
        return 256
        #endif
    }
    
    var body: some View {
        if viewModel.isLoggedIn {
            HStack(spacing: 0) {
                if viewModel.state.exchangeSceneState != .compactLeft {
                    VStack(spacing: 0) {
                        ExchangeSelectorView(
                            state: $viewModel.state.exchangeSceneState,
                            selectorState: $viewModel.exchangeSelectorState,
                            exchanges: viewModel.syncedExchanges,
                            panelWidth: leftPanelWidth
                        )
                        
                        TradingPairView(
                            traidingPairs: viewModel.tradingPairsForSelectedExchange,
                            selectedPair: $viewModel.currentPair,
                            searchRequest: $viewModel.searchRequest,
                            panelWidth: leftPanelWidth
                        )
                        
                        ExchangeBalancesView(
                            exchanges: viewModel.syncedExchanges,
                            tradingPairs: viewModel.allTraidingPairs,
                            state: $viewModel.exchangeBalancesSelectorState,
                            panelWidth: leftPanelWidth
                        )
                        
                        Spacer()
                    }
                    .frame(width: leftPanelWidth)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white)

                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ExchangeMarketView(
                                tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc(),
                                tradingData: viewModel.tradingData
                            )
                            .frame(minWidth: marketViewWidth, minHeight: 224)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            ExchangeMarketDataView(ticker: viewModel.currentPairTicker)

                            HStack(spacing: 32) {
                                BuySellView(
                                    side: .buy,
                                    exchange: viewModel.tradingData?.exchange,
                                    tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc(),
                                    ticker: viewModel.currentPairTicker,
                                    onOrderCreate: { type, side, amount, price in
                                        viewModel.placeOrder(type: type, side: side, amount: amount, price: price)
                                    }
                                )
                                .frame(minWidth: buySellViewWidth, maxWidth: .infinity)
                                .frame(height: 256)
                                
                                BuySellView(
                                    side: .sell,
                                    exchange: viewModel.tradingData?.exchange,
                                    tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc(),
                                    ticker: viewModel.currentPairTicker,
                                    onOrderCreate: { type, side, amount, price in
                                        viewModel.placeOrder(type: type, side: side, amount: amount, price: price)
                                    }
                                )
                                .frame(minWidth: buySellViewWidth, maxWidth: .infinity)
                                .frame(height: 256)
                            }
                            .padding(.horizontal, 32)
                            .alert(isPresented: $viewModel.showAlert) {
                                Alert(title: Text(viewModel.alert.title), message: Text(viewModel.alert.message), dismissButton: .default(Text("Dismiss"), action: {
                                    viewModel.showAlert = false
                                }))
                            }
                        }
                        
                        if viewModel.state.exchangeSceneState != .compactRight {
                            VStack(spacing: 0) {
                                OrderBookView(
                                    orderBook: viewModel.orderBook ?? SocketOrderBook(tradingPair: TradingPairModel.mltBtc(), data: NSDictionary()),
                                    tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc(),
                                    state: $viewModel.state.exchangeSceneState
                                )
                                .frame(width: rigthPanelWidth)//350
                                .frame(minHeight: 374, maxHeight: .infinity)

                                MyOrdersView(
                                    tradingPair: viewModel.currentPair ?? TradingPairModel.mltBtc(),
                                    orders: viewModel.orders, onOrderCancel: { order in
                                        viewModel.cancel(order: order)
                                    }
                                )
                                .frame(width: rigthPanelWidth, height: 256)
                            }

                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(paddingForState, 8)
            }
        } else {
            ExchangeSetup(viewModel: viewModel.setup)
        }
    }
}

struct ExchangeScene_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeScene(state: PortalState(), viewModel: ExchangeViewModel.config())
    }
}
