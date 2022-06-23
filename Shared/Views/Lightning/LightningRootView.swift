//
//  LightningRootView.swift
//  Portal
//
//  Created by farid on 6/2/22.
//

import SwiftUI

struct LightningRootView: View {
    @State private var state: ViewState
    @Binding var close: Bool
    
    init(state: LightningRootView.ViewState = .root, close: Binding<Bool>) {
        _state = State(initialValue: state)
        _close = close
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.portalBackground.border(.gray, width: 0.25).cornerRadius(5)
            
            switch state {
            case .root:
                LightningView(viewState: $state, close: $close)
            case .manage:
                ManageChannelsView(viewState: $state)
            case .openChannel:
                OpenNewChannelView(viewState: $state)
            case .receive:
                CreateInvoiceView(viewState: $state)
            case .fundChannel(let node):
                FundLightningChannelView(viewState: $state, node: node)
            case .send:
                PayInvoiceView(viewState: $state)
            case .paymentDetails(let payment):
                LightningPaymentDetailsView(viewState: $state, payment: payment)
            }
        }
    }
}

extension LightningRootView {
    enum ViewState {
        case root, manage, openChannel, fundChannel(LightningNode), receive, send, paymentDetails(LightningPayment)
    }
}

struct LightningRootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LightningRootView(state: .root, close: .constant(false))
            LightningRootView(state: .manage, close: .constant(false))
            LightningRootView(state: .openChannel, close: .constant(false))
            LightningRootView(state: .fundChannel(LightningNode.sampleNodes[0]), close: .constant(false))
            LightningRootView(state: .send, close: .constant(false))
            LightningRootView(state: .receive, close: .constant(false))
            LightningRootView(state: .paymentDetails(LightningPayment.samplePayment), close: .constant(false))
        }
    }
}
