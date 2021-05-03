//
//  ReceiveAssetsView.swift
//  Portal
//
//  Created by Farid on 19.04.2021.
//

import SwiftUI

struct ReceiveAssetsView: View {
    private let asset: IAsset
    @Binding var presented: Bool
    @State private var isCopied: Bool = false
        
    init(asset: IAsset, presented: Binding<Bool>) {
        self.asset = asset
        self._presented = presented
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 8)
                )
//                .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 2)
            
            asset.coin.icon
                .resizable()
                .frame(width: 64, height: 64)
                .offset(y: -32)
            
            HStack {
                Spacer()
                PButton(label: "Done", width: 73, height: 32, fontSize: 12, enabled: true) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        presented.toggle()
                    }
                }
            }
            .padding([.top, .trailing], 16)
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("Receive \(asset.coin.code)")
                        .font(.mainFont(size: 23))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                }
                .padding(.top, 57)
                .padding(.bottom, 16)
                
                Divider()
                    .padding(.vertical)
                
                HStack {
                    asset.qrCodeProvider.qrCode(address: "37hE3CUt3E8mLygaPdFYio8wyrWut31eYp")
                        .resizable()
                        .frame(width: 128, height: 128)
                    VStack(alignment: .leading) {
                        Text("Address")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Text("37hE3CUt3E8mLygaPdFYio8wyrWut31eYp")
                            .font(.mainFont(size: 16))
                            .foregroundColor(Color.coinViewRouteButtonInactive)
                        HStack(spacing: 12) {
                            PButton(label: "Copy to clipboard", width: 140, height: 32, fontSize: 12, enabled: true) {
                                withAnimation {
                                    isCopied.toggle()
                                }
                            }
                            
                            if isCopied {
                                Text("Copied to clipboard!")
                                    .font(.mainFont(size: 12))
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
        .frame(width: 576, height: 310)
    }
}

struct ReceiveAssetsView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveAssetsView(asset: Asset.bitcoin(), presented: .constant(false))
            .frame(width: 576, height: 350)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
