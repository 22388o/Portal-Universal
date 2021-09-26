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
                
                Selector
                
                HStack {
                    Text("Pair with")
                        .font(.mainFont(size: 12, bold: false))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.bottom, 6)
                
                PairSearchField(search: $searchRequest)
            }
            .padding(.horizontal, 32)
            
            if searchRequest.isEmpty {
                List(traidingPairs.filter{ selectedPair?.quote == $0.quote }.sorted{$0.change > $1.change}, id:\.id) { tradingPair in
                    TradingPairItem(traidingPair: tradingPair, selected: isSelected(tradingPair))
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPair = tradingPair
                        }
                }
                .listStyle(SidebarListStyle())
                .padding(.horizontal, 15)
            } else {
                List(traidingPairs.filter{ selectedPair?.quote == $0.quote && $0.base.lowercased().contains(searchRequest.lowercased()) }.sorted{$0.change > $1.change}, id:\.id) { tradingPair in
                    TradingPairItem(traidingPair: tradingPair, selected: isSelected(tradingPair))
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPair = tradingPair
                        }
                }
                .listStyle(SidebarListStyle())
                .padding(.horizontal, 15)
            }
        }
    }
    
    private var Selector: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(height: 32)
            
            HStack {
                if let tradingPair = selectedPair {
                    CoinImageView(size: 12, url: tradingPair.quote_icon)
                    Text(tradingPair.quote)
                    Spacer()
                    if traidingPairs.filter{ selectedPair?.base == $0.base }.count > 1 {
                        Image("optionArrowDown")
                    }
                }
            }
            .font(.mainFont(size: 12, bold: false))
            .foregroundColor(.gray)
            .padding(.leading, 10)
            .padding(.trailing, 16)
            
            if traidingPairs.filter{ selectedPair?.base == $0.base }.count > 1 {
                MenuButton(
                    label: EmptyView(),
                    content: {
                        ForEach(traidingPairs.filter{ selectedPair?.base == $0.base }.sorted(by: {$1.symbol > $0.symbol}), id: \.id) { tradingPair in
                            Button("\(tradingPair.quote)") {
                                selectedPair = tradingPair
                            }
                        }
                    }
                )
                .menuButtonStyle(BorderlessButtonMenuButtonStyle())
            }
        }
        .padding(.bottom, 20)
    }
    
    private func isSelected(_ tradingPair: TradingPairModel) -> Bool {
        selectedPair?.quote == tradingPair.quote && selectedPair?.base == tradingPair.base
    }
}

struct TradingPairView_Previews: PreviewProvider {
    static var previews: some View {
        TradingPairView(traidingPairs: [], selectedPair: .constant(TradingPairModel.mltBtc()), searchRequest: .constant(""))
    }
}
