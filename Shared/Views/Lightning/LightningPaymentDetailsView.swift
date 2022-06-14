//
//  LightningPaymentDetailsView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

struct LightningPaymentDetailsView: View {
    @Binding var viewState: LightningRootView.ViewState
    @StateObject private var viewModel: LightningPaymentDetailsViewModel

    init(viewState: Binding<LightningRootView.ViewState>, payment: LightningPayment) {
        _viewState = viewState
        _viewModel = StateObject(wrappedValue: LightningPaymentDetailsViewModel(payment: payment))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                ModalNavigationView(title: "Payment Details", backButtonAction: {
                    viewState = .root
                })
                .padding()
                
                VStack {
                    if let code = viewModel.qrCode {
                        Image(nsImage: code)
                            .resizable()
                            .frame(width: 350, height: 350)
                            .cornerRadius(10)
                    }
                    
                    HStack {
                        Text("Amount:")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        
                        Text("\(viewModel.payment.satAmount) sat")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightActiveLabel)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Description:")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        
                        Text("\(viewModel.payment.description)")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightActiveLabel)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Created:")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        
                        Text("\(viewModel.payment.created)")
                            .lineLimit(1)
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightActiveLabel)
                    }
                    .padding(.horizontal)
                    
                    if !viewModel.payment.isExpired {
                        HStack {
                            Text("Expires:")
                                .font(.mainFont(size: 14))
                                .foregroundColor(Color.lightInactiveLabel)
                            
                            Spacer()
                            
                            if let expireDate = viewModel.payment.expires {
                                Text("\(expireDate)")
                                    .lineLimit(1)
                                    .font(.mainFont(size: 14))
                                    .foregroundColor(Color.lightActiveLabel)
                            } else {
                                Text("-")
                                    .font(.mainFont(size: 14))
                                    .foregroundColor(Color.lightActiveLabel)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        HStack {
                            Text("Status:")
                                .font(.mainFont(size: 14))
                                .foregroundColor(Color.lightInactiveLabel)
                            
                            Spacer()
                            
                            Text("Expired")
                                .font(.mainFont(size: 14))
                                .foregroundColor(Color.lightActiveLabel)
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("Invoice:")
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightInactiveLabel)
                        .padding(.vertical)
                    
                    if let invoice = viewModel.payment.invoice {
                        Text("\(invoice)")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.white)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    if viewModel.payment.invoice != nil {
                        Button("Copy to clipboard") {
                            withAnimation {
                                viewModel.copyToClipboard()
                            }
                        }
                        .modifier(PButtonEnabledStyle(enabled: .constant(true)))
                        .padding()
                    }
                }
                .padding()
            }
        }
    }
}

struct LightningPaymentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            LightningPaymentDetailsView(viewState: .constant(.root), payment: LightningPayment.samplePayment)
        }
    }
}
