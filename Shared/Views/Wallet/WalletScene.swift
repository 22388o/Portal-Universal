//
//  WalletScene.swift
//  Portal
//
//  Created by Farid on 08.04.2021.
//

import SwiftUI

enum WalletSceneState {
    case full, walletPortfolio, walletAsset
}

struct WalletScene: View {
    let service: WalletsService
    @ObservedObject private var viewModel: ViewModel
    
    enum Scenes {
        case wallet, swap
    }
    
    @State private var state: Scenes = .wallet
            
    init(walletService: WalletsService) {
        self.service = walletService
        
        guard let wallet = walletService.currentWallet else {
            fatalError("There is no current wallet")
        }
        
        viewModel = .init(wallet: wallet)
    }
    
    var body: some View {
        ZStack(alignment: viewModel.switchWallet ? .topLeading : .center) {
            switch state {
            case .wallet:
                Color.portalWalletBackground//.transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .swap:
                Color.portalSwapBackground//.transition(AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }
            
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                viewModel.switchWallet.toggle()
                            }
                        }, label: {
                            HStack {
                                Text("\(viewModel.walletName)")
                                    .font(.mainFont(size: 14))
                                Image(systemName: "arrow.up.right.and.arrow.down.left.rectangle.fill")
                            }
                            .foregroundColor(Color.white.opacity(0.82))
                        })
                        
                        if state != .swap && viewModel.sceneState != .full {
                            Button(action: {
                                withAnimation {
                                    if viewModel.sceneState == .walletPortfolio {
                                        viewModel.sceneState = .walletAsset
                                    } else {
                                        viewModel.sceneState = .walletPortfolio
                                    }
                                }
                            }, label: {
                                Image(systemName: "aqi.medium")
                                    .foregroundColor(Color.white.opacity(0.82))
                            })
                        }
                        
                        Spacer()
                        
                        Text("Your wallet is stored locally")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.white.opacity(0.6))
                            
                    }
                    
                    AppSceneSwitch(state: $state)
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 24)
                
                ZStack {
                    Color.black.opacity(0.58)
                    
                    switch state {
                    case .wallet:
                        HStack(spacing: 0) {
                            if viewModel.sceneState == .full {
                                PortfolioView(viewModel: viewModel.portfolioViewModel)
                                WalletView(viewModel: viewModel)
                                AssetView(viewModel: viewModel)
                                    .padding([.top, .trailing, .bottom], 8)
                            } else {
                                if viewModel.sceneState == .walletPortfolio {
                                    PortfolioView(viewModel: viewModel.portfolioViewModel)
                                        .transition(.move(edge: .leading))
                                }
                                WalletView(viewModel: viewModel)
                                if viewModel.sceneState == .walletAsset {
                                    AssetView(viewModel: viewModel)
                                        .padding([.top, .trailing, .bottom], 8)
                                        .transition(.move(edge: .trailing))
                                }
                            }
                        }
                    case .swap:
                        Text("Swap")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }
                .cornerRadius(8)
                .padding([.leading, .bottom, .trailing], 24)
            }
            .blur(radius: viewModel.modalViewIsPresented ? 6 : 0)
            .scaleEffect(viewModel.scaleEffectRation)
            .allowsHitTesting(!viewModel.modalViewIsPresented)
            
            Group {
                Group {
                    if viewModel.sendAsset {
                        SendAssetView(wallet: viewModel.wallet, asset: viewModel.selectedAsset, presented: $viewModel.sendAsset)
                            .transition(.scale)
                    }
                    if viewModel.receiveAsset {
                        ReceiveAssetsView(asset: viewModel.selectedAsset, presented: $viewModel.receiveAsset)
                            .transition(.scale)
                    }
                    if viewModel.allTransactions {
                        AssetTxView(asset: viewModel.selectedAsset, presented: $viewModel.allTransactions)
                            .transition(.scale)
                    }
                    if viewModel.createAlert {
                        CreateAlertView(asset: viewModel.selectedAsset, presented: $viewModel.createAlert)
                            .transition(.scale)
                    }
                }
                .transition(.scale)
                
                if viewModel.switchWallet {
                    SwitchWalletsView(walletService: service, presented: $viewModel.switchWallet)
                        .padding(.top, 78)
                        .padding(.leading, 24)
                }
            }
            .zIndex(1)
        }
//        .preferredColorScheme(.dark)
    }
}

import Combine

extension WalletScene {
    final class ViewModel: ObservableObject {
        @Published var walletName: String
        @Published var selectedAsset: IAsset
        @Published var wallet: IWallet
        
        @Published var receiveAsset: Bool = false
        @Published var sendAsset: Bool = false
        @Published var switchWallet: Bool = false
        @Published var createAlert: Bool = false
        @Published var allTransactions: Bool = false
        @Published var searchRequest = String()
        @Published var sceneState: WalletSceneState
        
        @Published var assetViewRoute: AssetView.Route = .value
        
        @Published var modalViewIsPresented: Bool = false
        
        @ObservedObject var portfolioViewModel: PortfolioViewModel
        
        private var anyCancellable = Set<AnyCancellable>()
            
        var scaleEffectRation: CGFloat {
            if switchWallet {
                return 0.45
            } else if receiveAsset || sendAsset || allTransactions || createAlert {
                return 0.85
            } else {
                return 1
            }
        }
        
        init(wallet: IWallet) {
            print("WalletViewModel init")
            self.wallet = wallet
            self.walletName = wallet.name
            self.selectedAsset = wallet.assets.first ?? Asset.bitcoin()
            self.portfolioViewModel = .init(assets: wallet.assets)
            self.sceneState = UIScreen.main.bounds.width > 1180 ? .full : .walletAsset
            
            Publishers.MergeMany($receiveAsset, $sendAsset, $switchWallet, $allTransactions, $createAlert)
                .sink { [weak self] output in
                    self?.modalViewIsPresented = output
                }
                .store(in: &anyCancellable)
            
            print("wallet name: \(wallet.name)")
        }
        
        deinit {
            print("WalletScene view model deinit")
        }
    }
}

struct MainScene_Previews: PreviewProvider {
    static var previews: some View {
        WalletScene(walletService: .init(mockedWallet: WalletMock()))
            .iPadLandscapePreviews()
    }
}
