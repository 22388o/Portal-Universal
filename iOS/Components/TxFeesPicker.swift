//
//  TxFeesPicker.swift
//  Portal (iOS)
//
//  Created by farid on 1/3/22.
//

import SwiftUI

struct TxFeesPicker: View {
    let txFee: String
    let showOptions: Bool
    @Binding var txFeePriority: FeeRatePriority
    
    var body: some View {
        ZStack {
            if !txFee.isEmpty {
                if showOptions {
                    Rectangle()
                        .padding(.top, 20)
                        .overlay(
                            Menu {
                                Button("\(FeeRatePriority.low.title) ~ 60 min") {
                                    txFeePriority = .low
                                }
                                Button("\(FeeRatePriority.medium.title) ~ 30 min") {
                                    txFeePriority = .medium
                                }
                                Button("\(FeeRatePriority.high.title) ~ 10 min") {
                                    txFeePriority = .high
                                }
                            } label: {
                                HStack {
                                    Text("Tx fee: \(txFee)")
                                        .font(.mainFont(size: 12))
                                        .foregroundColor(Color.coinViewRouteButtonInactive)
                                    
                                    Text("\(txFeePriority.title)")
                                        .underline()
                                        .foregroundColor(Color.txListTxType)
                                        .contentShape(Rectangle())
                                }
                            }
                        )
                } else {
                    Text("Tx fee: \(txFee)")
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.coinViewRouteButtonInactive)
                }
            } else {
                Text(" ")
                    .font(.mainFont(size: 12))
                    .foregroundColor(Color.coinViewRouteButtonInactive)
            }
        }
    }
}

struct TxFeesPicker_Previews: PreviewProvider {
    static var previews: some View {
        TxFeesPicker(txFee: String(), showOptions: true, txFeePriority: .constant(.recommended))
            .frame(width: 120, height: 48)
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
