//
//  TxFeesPicker.swift
//  Portal (macOS)
//
//  Created by farid on 1/3/22.
//

import SwiftUI

struct TxFeesPicker: View {
    let txFee: String
    @Binding var txFeePriority: FeeRatePriority
    
    var body: some View {
        ZStack {
            HStack {
                Text("Tx fee: \(txFee)")
                    .font(.mainFont(size: 12))
                    .foregroundColor(Color.coinViewRouteButtonInactive)
                
                Text("\(txFeePriority.title)")
                    .underline()
                    .foregroundColor(Color.txListTxType)
                    .contentShape(Rectangle())
            }
            
            MenuButton(
                label: EmptyView(),
                content: {
                    Button("\(FeeRatePriority.low.title) ~ 60 min") {
                        txFeePriority = .low
                    }
                    Button("\(FeeRatePriority.medium.title) ~ 30 min") {
                        txFeePriority = .medium
                    }
                    Button("\(FeeRatePriority.high.title) ~ 10 min") {
                        txFeePriority = .high
                    }
                }
            )
            .menuButtonStyle(BorderlessButtonMenuButtonStyle())
            .frame(width: 120)
            .offset(x: 90)
        }
    }
}


struct TxFeesPicker_Previews: PreviewProvider {
    static var previews: some View {
        TxFeesPicker(txFee: String(), txFeePriority: .constant(.recommended))
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
