//
//  WalletScene.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI


struct WalletScene: View {
    let wallet: IWallet
    @ObservedObject private var viewModel: ViewModel
            
    init(wallet: IWallet) {
        self.wallet = wallet
        viewModel = .init(name: wallet.name, assets: wallet.assets)
    }
    
    var body: some View {
        ZStack {
            Color.portalGradientBackground
            
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Text("\(viewModel.walletName)")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.white.opacity(0.82))
                        
                        Spacer()
                        
                        Text("Your wallet is stored locally")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.white.opacity(0.6))
                            
                    }
                    
                    WalletExchangeSwitch()
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 24)
                
                ZStack {
                    Color.black.opacity(0.58)
                    HStack(spacing: 0) {
                        PortfolioView(viewModel: .init(assets: viewModel.assets))
                        WalletView(viewModel: viewModel)
                        AssetView(viewModel: viewModel)
                            .padding([.top, .trailing, .bottom], 8)
                    }
                }
                .cornerRadius(8)
                .padding([.leading, .bottom, .trailing], 24)
            }
            .blur(radius: viewModel.modalViewIsPresented ? 4 : 0)
            
            if viewModel.sendAsset {
                SendAssetView(wallet: wallet, asset: viewModel.selectedAsset, show: $viewModel.sendAsset)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
            if viewModel.receiveAsset {
                ReceiveAssetsView(asset: viewModel.selectedAsset, show: $viewModel.receiveAsset)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
            if viewModel.allTransactions {
                AssetTxView(asset: viewModel.selectedAsset, show: $viewModel.allTransactions)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

import Combine

extension WalletScene {
    final class ViewModel: ObservableObject {
        @Published var walletName: String
        @Published var selectedAsset: IAsset
        @Published var assets: [IAsset]
        
        @Published var receiveAsset: Bool = false
        @Published var sendAsset: Bool = false
        @Published var sendAssetToExchange: Bool = false
        @Published var withdrawAssetFromExchange: Bool = false
        @Published var allTransactions: Bool = false
        @Published var searchRequest = String()
        
        @Published var assetViewRoute: AssetView.Route = .value
        
        @Published var modalViewIsPresented: Bool = false
        
        private var anyCancellable = Set<AnyCancellable>()
            
        init(name: String, assets: [IAsset]) {
            print("WalletViewModel init")
            self.assets = assets
            self.walletName = name
            self.selectedAsset = assets.first ?? Asset.bitcoin()
            
            Publishers.MergeMany($receiveAsset, $sendAsset, $sendAssetToExchange, $withdrawAssetFromExchange, $allTransactions)
                .sink { [weak self] output in
                    self?.modalViewIsPresented = output
                }
                .store(in: &anyCancellable)
            
        }
    }
}

struct MainScene_Previews: PreviewProvider {
    static var previews: some View {
        WalletScene(wallet: WalletMock())
            .iPadLandscapePreviews()
    }
}
