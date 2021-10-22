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
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 6)
                )
            
            CoinImageView(size: 64, url: coin.icon, placeholderForegroundColor: .black)
                .background(Color.white)
                .cornerRadius(32)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.black, lineWidth: 1)
                )
                .offset(y: -32)
                        
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
                            .frame(width: 128, height: 128)
                    }
                    VStack(alignment: .leading) {
                        Text("Address")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Text(viewModel.receiveAddress)
                            .font(.mainFont(size: 16))
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
                    Spacer()
                }
                
                Divider()
                    .padding(.vertical)
            }
            .padding(.horizontal, 40)
        }
        .allowsHitTesting(true)
        .frame(width: 630, height: 310)
        .onAppear {
            viewModel.update()
        }
    }
}

struct ReceiveAssetsView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveAssetsView(coin: Coin.bitcoin())
            .frame(width: 576, height: 350)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
