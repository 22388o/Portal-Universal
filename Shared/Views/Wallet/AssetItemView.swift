//
//  AssetItemView.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct AssetItemView: View {
    @ObservedObject var viewModel: AssetViewModel
    let selected: Bool
            
    init(viewModel: AssetViewModel, selected: Bool) {
        self.viewModel = viewModel
        self.selected = selected
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
                }
                .padding(.horizontal, 20)
                
                Text(viewModel.totalValue)
                    .transition(.identity)
            }
            .font(.mainFont(size: 18))
            .foregroundColor(selected ? .black : .white)
        }
        .frame(height: 64)
        .contentShape(Rectangle())
    }
}

struct AssetItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AssetItemView(
                viewModel: AssetViewModel(asset: Asset.bitcoin()),
                selected: true
            )
            
            AssetItemView(
                viewModel: AssetViewModel(asset: Asset.bitcoin()),
                selected: false
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
