//
//  ReceiveAssetsView.swift
//  Portal
//
//  Created by Farid on 19.04.2021.
//

import SwiftUI

struct ReceiveAssetsView: View {
    private let coin: Coin
    @ObservedObject private var viewModel: ReceiveAssetViewModel
    @ObservedObject private var state = Portal.shared.state
        
    init(coin: Coin) {
        self.coin = coin
        self.viewModel = ReceiveAssetViewModel.config(coin: coin)
    }
    
    var body: some View {
        #if os(macOS)
        ModalViewContainer(imageUrl: coin.icon, size: CGSize(width: 630, height: 310)) {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("Receive \(coin.name)")
                        .font(.mainFont(size: 23))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                }
                .padding(.top, 57)
                .padding(.bottom, 16)
                
                Divider()
                    .padding(.vertical)
                
                HStack {
                    if let image = viewModel.qrCode {
                        image
                            .resizable()
                            .frame(width: 180, height: 180)
                    }
                    VStack(alignment: .leading) {
                        Text("Address")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Text(viewModel.receiveAddress)
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.coinViewRouteButtonInactive)
                        
                        Spacer().frame(height: 25)
                        
                        HStack(spacing: 12) {
                            PButton(label: "Copy to clipboard", width: 140, height: 32, fontSize: 12, enabled: true) {
                                viewModel.copyToClipboard()
                                
                                if viewModel.isCopied != true {
                                    withAnimation {
                                        viewModel.isCopied = true
                                    }
                                }
                            }
                            .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                            
                            if viewModel.isCopied {
                                Text("Copied to clipboard!")
                                    .font(.mainFont(size: 12))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                
                Divider()
                    .padding(.vertical)
            }
            .padding(.horizontal, 40)
        }
        .allowsHitTesting(true)
        .onAppear {
            viewModel.update()
        }
        #else
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Text("Receive \(coin.name)")
                    .font(.mainFont(size: 23))
                    .foregroundColor(Color.coinViewRouteButtonActive)
            }
            .padding(.top, 57)
            .padding(.bottom, 16)
            
            Divider()
                .padding(.vertical)
            
            VStack {
                if let image = viewModel.qrCode {
                    image
                        .resizable()
                        .frame(width: 300, height: 300)
                }
                VStack(alignment: .leading) {
                    Text("Address")
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                    Text(viewModel.receiveAddress)
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.coinViewRouteButtonInactive)
                    
                    Spacer().frame(height: 25)
                    
                    HStack(spacing: 12) {
                        PButton(label: "Copy to clipboard", width: 140, height: 32, fontSize: 12, enabled: true) {
                            viewModel.copyToClipboard()
                            
                            if viewModel.isCopied != true {
                                withAnimation {
                                    viewModel.isCopied = true
                                }
                            }
                        }
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                        
                        if viewModel.isCopied {
                            Text("Copied to clipboard!")
                                .font(.mainFont(size: 12))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.leading)
                
                Spacer()
            }
        }
        .padding(.horizontal, 40)
        #endif
    }
}

struct ReceiveAssetsView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveAssetsView(coin: Coin.bitcoin())
            .frame(width: 650, height: 350)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
