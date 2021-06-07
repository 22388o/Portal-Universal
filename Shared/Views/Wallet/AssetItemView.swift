//
//  AssetItemView.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI
import Coinpaprika

struct AssetItemView: View {
    private var viewModel: AssetItemViewModel
    let selected: Bool
    let onTap: () -> ()
            
    init(asset: IAsset, marketData: MarketDataRepository?, selected: Bool, fiatCurrency: FiatCurrency, onTap: @escaping () -> ()) {
        self.viewModel = .init(asset: asset, marketData: marketData, selectedTimeFrame: .day, fiatCurrency: fiatCurrency)
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
                        viewModel.asset.coin.icon
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("\(viewModel.asset.balanceProvider.balanceString) \(viewModel.asset.coin.code)")
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
                asset: Asset.bitcoin(),
                marketData: nil,
                selected: true,
                fiatCurrency: USD,
                onTap: {}
            )
            
            AssetItemView(
                asset: Asset.bitcoin(),
                marketData: nil,
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
