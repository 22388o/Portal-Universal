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
            
    init(coin: Coin, viewModel: AssetItemViewModel, selected: Bool, onTap: @escaping () -> ()) {
        self.coin = coin
        self.viewModel = viewModel
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
                            CoinImageView(size: 24, url: viewModel.coin.icon)
                        }
                        .frame(width: 26, height: 26)
                        
                        if viewModel.adapterState != .synced {
                            HStack {
                                Text(viewModel.balanceString)
                                Text(viewModel.syncProgressString)
                                    .font(.mainFont(size: 16))
                                    .foregroundColor(selected ? .gray : Color(red: 160/255, green: 190/255, blue: 186/255, opacity: 1))
                            }
                        } else {
                            Text(viewModel.balanceString)
                        }
                    }
                    
                    Spacer()
                    
                    Text(viewModel.changeString)
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
                viewModel: AssetItemViewModel.config(coin: Coin.bitcoin(), adapter: MockedBalanceAdapter()),
                selected: true,
                onTap: {}
            )
            
            AssetItemView(
                coin: Coin.bitcoin(),
                viewModel: AssetItemViewModel.config(coin: Coin.bitcoin(), adapter: MockedBalanceAdapter()),
                selected: false,
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
