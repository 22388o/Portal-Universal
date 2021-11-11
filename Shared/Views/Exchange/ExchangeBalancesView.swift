//
//  ExchangeBalancesView.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import SwiftUI

enum BalaceSelectorState {
    case merged, selected(exchange: ExchangeModel)
    
    var isMerged: Bool {
        switch self {
        case .merged:
            return true
        default:
            return false
        }
    }
}

struct ExchangeBalancesView: View {
    let exchanges: [ExchangeModel]
    let tradingPairs: [TradingPairModel]
    @Binding var state: BalaceSelectorState
    let panelWidth: CGFloat
    
    private var balances: [ExchangeBalanceModel] {
        switch state {
        case .merged:
            return exchanges.map{ $0.balances }.reduce([ExchangeBalanceModel](), { $0 + $1 })
        case .selected(let exchange):
            return exchange.balances
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.10))
                .frame(height: 1)
                .offset(y: -1)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Balance in exchange")
                        .font(.mainFont(size: 15, bold: false))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 25)
                .padding(.bottom, 12)
                .padding(.horizontal, 32)
                
                ExchangeBalancePicker(state: $state, exchanges: exchanges)
                    .padding(.horizontal, panelWidth == 320 ? 32 : 20)
                    .padding(.bottom, 6)
                
                List(balances, id:\.id) { balance in
                    ExchangeBalanceItem(
                        balanceItem: balance,
                        iconUrl: tradingPairs.first(where: {$0.base == balance.asset})?.icon,
                        selected: false
                    )
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .contentShape(Rectangle())
                }
                .listStyle(SidebarListStyle())
                .padding(.horizontal, panelWidth == 320 ? 15 : 2)
                
                Spacer()
            }
        }
        .frame(height: 256)
    }
}

struct ExchangeBalancesView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeBalancesView(exchanges: [], tradingPairs: [], state: .constant(.merged), panelWidth: 320)
    }
}
