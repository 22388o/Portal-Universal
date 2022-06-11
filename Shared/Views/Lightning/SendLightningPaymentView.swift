//
//  SendLightningPaymentView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

struct SendLightningPaymentView: View {
    @Binding var viewState: LightningRootView.ViewState
    
    var body: some View {
        VStack {
            ModalNavigationView(title: "Send Lightning Payment", backButtonAction: {
                viewState = .root
            })
            .padding()
        }
    }
}

struct SendLightningPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        SendLightningPaymentView(viewState: .constant(.send))
            .frame(width: 500, height: 650)
            .padding()
    }
}
