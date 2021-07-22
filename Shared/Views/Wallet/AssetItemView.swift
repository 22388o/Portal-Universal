//
//  AssetItemView.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct AssetItemView: View {
    @ObservedObject private var viewModel: AssetItemViewModel
    let coin: Coin
    let selected: Bool
    let onTap: () -> ()
            
    init(coin: Coin, adapter: IBalanceAdapter, selected: Bool, fiatCurrency: FiatCurrency, onTap: @escaping () -> ()) {
        self.coin = coin
        self.viewModel = .init(
            coin: coin,
            adapter: adapter,
            selectedTimeFrame: .day,
            fiatCurrency: fiatCurrency,
            ticker: Portal.shared.marketDataProvider.ticker(coin: coin)
        )
        self.selected = selected
        self.onTap = onTap
    }
        
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(selected ? Color.white : Color.clear)
            
            ZStack {
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            if viewModel.adapterState != .synced {
                                CircularProgressBar(progress: $viewModel.syncProgress)
                                    .frame(width: 26, height: 26)
                            }
                            coin.icon
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .frame(width: 26, height: 26)
                        
                        Text("\(viewModel.balance) \(coin.code)")
                    }
                    
                    Spacer()
                    
                    Text(viewModel.change)
                        .foregroundColor(viewModel.changeLabelColor)
                }
                .padding(.horizontal, 20)
                
                Text(viewModel.totalValue)
                    .transition(.identity)
            }
            .font(.mainFont(size: 18))
            .foregroundColor(selected ? .black : Color(red: 160/255, green: 190/255, blue: 186/255, opacity: 1))
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
        }
        .frame(height: 64)
    }
}

struct AssetItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AssetItemView(
                coin: Coin.bitcoin(),
                adapter: MockedBalanceAdapter(),
                selected: true,
                fiatCurrency: USD,
                onTap: {}
            )
            
            AssetItemView(
                coin: Coin.bitcoin(),
                adapter: MockedBalanceAdapter(),
                selected: false,
                fiatCurrency: USD,
                onTap: {}
            )
        }
        .frame(width: 600, height: 64)
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .background(
            ZStack {
                Color.portalWalletBackground
                Color.black.opacity(0.58)
            }
        )
    }
}

import RxSwift

struct MockedBalanceAdapter: IBalanceAdapter {
    var balanceState: AdapterState = .synced
    
    var balanceStateUpdatedObservable: Observable<Void> = Observable.just(())
    
    var balance: Decimal = 2.25
    
    var balanceUpdatedObservable: Observable<Void> = Observable.just(())
    
    init() {}
}
