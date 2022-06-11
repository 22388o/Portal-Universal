//
//  LightningPaymentDetailsView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

struct LightningPaymentDetailsView: View {
    @Binding var viewState: LightningRootView.ViewState
    let payment: LightningPayment
    
    var body: some View {
        ZStack {
            Text("Payment Details")
                .font(.mainFont(size: 18))
                .foregroundColor(Color.white)
                .padding()
            
            HStack {
                Text("Back")
                    .foregroundColor(Color.lightActiveLabel)
                    .font(.mainFont(size: 14))
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            viewState = .root
                        }
                    }
                Spacer()
            }
        }
        .padding()
    }
}

struct LightningPaymentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        LightningPaymentDetailsView(viewState: .constant(.root), payment: LightningPayment.samplePayment)
            .frame(width: 500, height: 650)
            .padding()
    }
}
