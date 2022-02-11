//
//  AssetItemView.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct AssetItemView: View {
    @ObservedObject private var viewModel: AssetItemViewModel
    let onTap: () -> ()
            
    init(viewModel: AssetItemViewModel, onTap: @escaping () -> ()) {
        self.viewModel = viewModel
        self.onTap = onTap
    }
        
    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(viewModel.selected ? Color.white : Color.clear)
                
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
                                VStack(alignment: .leading) {
                                    Text(viewModel.balanceString)
                                    if !viewModel.syncProgressString.isEmpty {
                                        Text(viewModel.syncProgressString)
                                            .font(.mainFont(size: 14))
                                            .foregroundColor(viewModel.selected ? .gray : Color(red: 160/255, green: 190/255, blue: 186/255, opacity: 1))
                                    }
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
                    
                    Text(viewModel.totalValueString)
                        .transition(.identity)
                }
                .font(.mainFont(size: 18))
                .foregroundColor(viewModel.selected ? .black : Color(red: 160/255, green: 190/255, blue: 186/255, opacity: 1))
                .contentShape(Rectangle())
            }
        }
        .frame(height: 64)
        .buttonStyle(PlainButtonStyle())
        .identifier(viewModel.coin.code + " Asset Button Identifier")
    }
}

struct AssetItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AssetItemView(
                viewModel: AssetItemViewModel.config(coin: Coin.bitcoin(), adapter: MockedBalanceAdapter()),
                onTap: {}
            )
            
            AssetItemView(
                viewModel: AssetItemViewModel.config(coin: Coin.bitcoin(), adapter: MockedBalanceAdapter()),
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
