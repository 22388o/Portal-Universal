//
//  LightningPaymentDetailsView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

struct LightningPaymentDetailsView: View {
    @Binding var state: LightningRootView.ViewState
    let payment: LightningPayment
    
    var body: some View {
        Text("LightningPaymentDetailsView")
    }
}

struct LightningPaymentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        LightningPaymentDetailsView(state: .constant(.root), payment: LightningPayment.samplePayment)
            .frame(width: 500, height: 650)
            .padding()
    }
}
