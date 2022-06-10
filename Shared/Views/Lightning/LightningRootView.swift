//
//  LightningRootView.swift
//  Portal
//
//  Created by farid on 6/2/22.
//

import SwiftUI

struct LightningRootView: View {
    @State private var state: ViewState
    
    init(state: LightningRootView.ViewState = .root) {
        _state = State(initialValue: state)
    }
    
    var body: some View {
        ModalViewContainer(size: CGSize(width: 500, height: 650), {
            ZStack(alignment: .top) {
                Color.portalBackground.edgesIgnoringSafeArea(.all)
                
                switch state {
                case .root:
                    LightningView(viewState: $state)
                case .manage:
                    ManageChannelsView(viewState: $state)
                case .openChannel:
                    OpenNewChannelView(viewState: $state)
                case .receive:
                    CreateInvoiceView(viewState: $state)
                case .fundChannel:
                    FundLightningChannelView(viewState: $state)
                case .send:
                    SendLightningPaymentView(viewState: $state)
                case .paymentDetails(let payment):
                    LightningPaymentDetailsView(viewState: $state, payment: payment)
                }
            }
        })
    }
}

extension LightningRootView {
    enum ViewState {
        case root, manage, openChannel, fundChannel, receive, send, paymentDetails(LightningPayment)
    }
}

struct LightningRootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LightningRootView(state: .root)
            LightningRootView(state: .manage)
            LightningRootView(state: .openChannel)
            LightningRootView(state: .fundChannel)
            LightningRootView(state: .send)
            LightningRootView(state: .receive)
            LightningRootView(state: .paymentDetails(LightningPayment.samplePayment))
        }
    }
}
