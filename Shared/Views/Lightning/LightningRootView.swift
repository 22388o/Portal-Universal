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
                    EmptyView()
                case .send:
                    SendLightningPaymentView(state: $state)
                case .paymentDetails(let payment):
                    EmptyView()
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
        }
    }
}
