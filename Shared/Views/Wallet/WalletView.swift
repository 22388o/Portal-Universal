//
//  WalletView.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

struct WalletView: View {
    @ObservedObject private var viewModel: WalletScene.ViewModel
    
    init(viewModel: WalletScene.ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                AssetSearchField()
                FiatCurrencyButton()
            }
            .padding([.top, .horizontal], 24)
            .padding(.bottom, 19)
            
            HStack {
                Text("Asset")
                Spacer()
                Text("Value")
                Spacer()
                Text("Change")
            }
            .font(.mainFont())
            .foregroundColor(Color.white.opacity(0.5))
            .padding(.horizontal, 55)
            
            Divider()
                .background(Color.white.opacity(0.11))
                .padding(.top, 12)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.assets, id: \.id) { asset in
                        AssetItemView(
                            viewModel: AssetViewModel(asset: asset),
                            selected: viewModel.selectedAsset.id == asset.id
                        )
                        .onTapGesture {
                            if asset.coin.code != viewModel.selectedAsset.coin.code {
                                viewModel.selectedAsset = asset
                            }
                        }
                    }
                }
                .offset(y: 20)
            }
            .padding(.horizontal, 24)
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalGradientBackground
            Color.black.opacity(0.58)
            WalletView(viewModel: WalletScene.ViewModel(name: "Personal", assets: WalletMock().assets))
        }
        .frame(width: .infinity, height: 430)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
