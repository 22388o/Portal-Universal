//
//  ExchangeMarketDataView.swift
//  Portal
//
//  Created by Farid on 07.10.2021.
//

import SwiftUI

struct ExchangeMarketDataView: View {
    let ticker: SocketTicker
    
    var body: some View {
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
        .lineLimit(1)
        .font(.mainFont(size: 12, bold: false))
        .foregroundColor(Color.gray)
        .padding(.horizontal, 32)
        .padding(.bottom, 28)
        
        Rectangle()
            .foregroundColor(Color.exchangeBorderColor)
            .frame(height: 1)
    }
}
