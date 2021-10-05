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
    @Binding var state: BalaceSelectorState
    
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
                
                Selector
                    .padding(.horizontal, 32)
                
                List(balances, id:\.id) { item in
                    ExchangeBalanceItem(balanceItem: item, selected: false)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .contentShape(Rectangle())
                }
                .listStyle(SidebarListStyle())
                .padding(.horizontal, 15)
                
                Spacer()
            }
        }
        .frame(height: 256)
    }
    
    private var Selector: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 88/255, green: 106/255, blue: 130/255, opacity: 0.3))
                .frame(height: 32)
            
            HStack {
                switch state {
                case .merged:
                    Image("iconAllExchangesMergedDark")
                    Text("All exchanges merged")
                case .selected(let exchange):
                    CoinImageView(size: 12, url: exchange.icon)
                    Text(exchange.name)
                }
                Spacer()
                if exchanges.count > 1 {
                    Image("optionArrowDownDark")
                }
            }
            .font(.mainFont(size: 12, bold: false))
            .foregroundColor(.gray)
            .padding(.leading, 10)
            .padding(.trailing, 16)
            
            if exchanges.count > 1 {
                MenuButton(
                    label: EmptyView(),
                    content: {
                        Button("All exchange merged") {
                            state = .merged
                        }
                        ForEach(exchanges, id: \.id) { exchange in
                            Button("\(exchange.name)") {
                                state = .selected(exchange: exchange)
                            }
                        }
                    }
                )
                .menuButtonStyle(BorderlessButtonMenuButtonStyle())
            }
        }
        .padding(.bottom, 6)
    }
}

struct ExchangeBalancesView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeBalancesView(exchanges: [], state: .constant(.merged))
    }
}
