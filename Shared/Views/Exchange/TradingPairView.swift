//
//  TradingPairView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

struct TradingPairView: View {
    let traidingPairs: [TradingPairModel]
    @Binding var selectedPair: TradingPairModel?
    @Binding var searchRequest: String
    let panelWidth: CGFloat
            
    var body: some View {
        VStack(spacing: 0) {
            Group {
                HStack {
                    Text("Trading currency")
                        .font(.mainFont(size: 12, bold: false))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 25)
                .padding(.bottom, 12)
                
                TradingPairPicker(selectedPair: $selectedPair, traidingPairs: traidingPairs)
                    .padding(.bottom, 20)
                
                HStack {
                    Text("Pair with")
                        .font(.mainFont(size: 12, bold: false))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.bottom, 6)
                
                PairSearchField(search: $searchRequest)
            }
            .padding(.horizontal, panelWidth == 320 ? 32 : 20)
            
            List(tradingPairsToShow(), id:\.id) { tradingPair in
                TradingPairItem(traidingPair: tradingPair, selected: isSelected(tradingPair))
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPair = tradingPair
                    }
            }
            .listStyle(SidebarListStyle())
            .padding(.horizontal, panelWidth == 320 ? 15 : 2)
        }
    }
    
    private func isSelected(_ tradingPair: TradingPairModel) -> Bool {
        selectedPair?.quote == tradingPair.quote && selectedPair?.base == tradingPair.base
    }
    
    private func tradingPairsToShow() -> [TradingPairModel] {
        if searchRequest.isEmpty {
            return traidingPairs.filter{ selectedPair?.quote == $0.quote }.sorted{$0.change > $1.change}
        } else {
            return traidingPairs.filter{ selectedPair?.quote == $0.quote && $0.base.lowercased().contains(searchRequest.lowercased()) }.sorted{$0.change > $1.change}
        }
    }
}

struct TradingPairView_Previews: PreviewProvider {
    static var previews: some View {
        TradingPairView(traidingPairs: [], selectedPair: .constant(TradingPairModel.mltBtc()), searchRequest: .constant(""), panelWidth: 320)
    }
}
