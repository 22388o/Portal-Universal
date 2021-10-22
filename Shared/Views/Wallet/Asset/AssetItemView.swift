//
//  AssetItemView.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct AssetItemView: View {
    @ObservedObject private var viewModel: AssetItemViewModel
    let selected: Bool
    let onTap: () -> ()
            
    init(viewModel: AssetItemViewModel, selected: Bool, onTap: @escaping () -> ()) {
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
                        
                        Text(viewModel.balanceString)
                    }
                    
                    Spacer()
                    
                    Text(viewModel.changeString)
                        .foregroundColor(viewModel.changeLabelColor)
                }
                .padding(.horizontal, 20)
                
                Text(viewModel.totalValueString)
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
                viewModel: AssetItemViewModel.config(coin: Coin.bitcoin(), adapter: MockedBalanceAdapter()),
                selected: true,
                onTap: {}
            )
            
            AssetItemView(
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
