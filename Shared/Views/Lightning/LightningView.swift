//
//  LightningView.swift
//  Portal
//
//  Created by farid on 6/9/22.
//

import SwiftUI

struct LightningView: View {
    @Binding var viewState: LightningRootView.ViewState
    @StateObject private var viewModel = LightningRootViewViewModel.config()
    
    var body: some View {
        VStack {
            HStack {
                Text("Channels")
                    .font(.mainFont(size: 18))
                    .foregroundColor(Color.white)
                Spacer()
                
                Text("Manage")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.lightActiveLabel)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            viewState = .manage
                        }
                    }
            }
            .padding()
            
            VStack {
                HStack {
                    Text("On-chain")
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    
                    Text(viewModel.onChainBalanceString)
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightActiveLabel)
                }
                
                HStack {
                    Text("Lightning")
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    
                    Text(viewModel.channelsBalanceString)
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightActiveLabel)
                }
                
                HStack {
                    PButtonDark(label: "Recieve", height: 40, fontSize: 16, enabled: true, action: {
                        withAnimation {
                            viewState = .receive
                        }
                    })

                    PButtonDark(label: "Send", height: 40, fontSize: 16, enabled: true, action: {
                        withAnimation {
                            viewState = .send
                        }
                    })
                }
            }
            .padding()
            
            HStack {
                Text("Payments")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.white)
                Spacer()
            }
            .padding([.horizontal])
            
            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if viewModel.payments.isEmpty {
                Spacer()
                Text("There is no payments.")
                    .font(.mainFont(size: 14))
                    .foregroundColor(Color.lightActiveLabel)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.payments) { payment in
                            LightningPaymentItemView(payment: payment)
                                .onTapGesture {
                                    withAnimation {
                                        viewState = .paymentDetails(payment)
                                    }
                                }
                        }
                        .frame(height: 80)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .onAppear {
            viewModel.refreshPayments()
        }
    }
}

struct LightningView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            LightningView(viewState: .constant(.root))
        }
    }
}
