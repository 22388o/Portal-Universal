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
            ZStack {
                Text("Send Lightning Payment")
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
}

struct SendLightningPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        SendLightningPaymentView(viewState: .constant(.send))
            .frame(width: 500, height: 650)
            .padding()
    }
}
