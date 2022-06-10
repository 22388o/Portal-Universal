//
//  SendLightningPaymentView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

struct SendLightningPaymentView: View {
    @Binding var state: LightningRootView.ViewState
    
    var body: some View {
        EmptyView()
    }
}

struct SendLightningPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        SendLightningPaymentView(state: .constant(.send))
            .frame(width: 500, height: 650)
            .padding()
    }
}
