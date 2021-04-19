//
//  SendAssetView.swift
//  Portal
//
//  Created by Farid on 12.04.2021.
//

import SwiftUI

struct SendAssetView: View {
    let asset: IAsset
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.7), lineWidth: 8)
                )
                .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 2)
            
            asset.coin.icon
                .resizable()
                .frame(width: 64, height: 64)
                .offset(y: -32)
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    VStack {
                        Text("Send \(asset.coin.code)")
                            .font(.mainFont(size: 23))
                        Text("Instantly send to any \(asset.coin.code) address")
                            .font(.mainFont(size: 14))
                    }
                    VStack {
                        Text("You have \(asset.balanceProvider.balance(currency: .fiat(USD))) \(asset.coin.code)")
                            .font(.mainFont(size: 12))
                        Text("0.0000012 \(asset.coin.code) tx fee - Normal Speed")
                            .font(.mainFont(size: 12))
                    }
                }
                .padding(.top, 57)
                .padding(.bottom, 16)
                                
                VStack(spacing: 23) {
                    ExchangerView(viewModel: .init(asset: asset.coin, fiat: USD))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Send to...")
                            .font(.mainFont(size: 12))
                        PTextField(text: .constant(""), placeholder: "Reciever address", upperCase: false, width: 480, height: 48)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Private description / memo (optional)")
                            .font(.mainFont(size: 12))
                        PTextField(text: .constant(""), placeholder: "Enter private description or memo", upperCase: false, width: 480, height: 48)
                    }
                }
                                
                PButton(label: "Send", width: 334, height: 48, fontSize: 14, enabled: true) {
                    
                }
                .padding(.top, 16)
                .padding(.bottom, 27)
                
                HStack(spacing: 0) {
                    Text("Status")
                    Text("Amount")
                        .padding(.leading, 66)
                    Text("Sent to…")
                        .padding(.leading, 44)
                    Spacer()
                }
                .font(.mainFont(size: 12))
                .frame(width: 480)
                
                Spacer().frame(height: 8)
                
                Divider()
                
                Rectangle()
                    .fill(Color.exchangerFieldBackground)
                    .padding([.horizontal, .bottom], 4)
            }
        }
        .frame(width: 576, height: 662)
    }
}

struct SendAssetView_Previews: PreviewProvider {
    static var previews: some View {
        SendAssetView(asset: Asset.bitcoin())
            .frame(width: 576, height: 662)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
