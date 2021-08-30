//
//  ExchangeScene.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct ExchangeScene: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                ExchangeSelectorView()
                TradingPairView()
                ExchangeBalancesView()
                Spacer()
            }
            .frame(width: 320)
            
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.94))
                
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ExchangeMarketView()
                            .frame(minWidth: 606, minHeight: 374)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .overlay(
//                                Rectangle()
//                                    .stroke(Color.exchangerFieldBorder.opacity(0.94), lineWidth: 1)
//                            )
                        
                        HStack(spacing: 0) {
                            BuySellView()
                                .frame(minWidth: 303, maxWidth: .infinity)
                                .frame(height: 256)
                            BuySellView()
                                .frame(minWidth: 303, maxWidth: .infinity)
                                .frame(height: 256)
                        }
                    }
                    
                    VStack(spacing: 0) {
                        OrderBookView()
                            .frame(width: 296)
                            .frame(minHeight: 374, maxHeight: .infinity)
//                            .overlay(
//                                Rectangle()
//                                    .stroke(Color.exchangerFieldBorder.opacity(0.94), lineWidth: 1)
//                            )
                        MyOrdersView()
                            .frame(width: 296, height: 256)
//                            .overlay(
//                                Rectangle()
//                                    .stroke(Color.exchangerFieldBorder.opacity(0.94), lineWidth: 1)
//                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(8)
        }
    }
}

struct ExchangeScene_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeScene()
            .iPadLandscapePreviews()
    }
}
