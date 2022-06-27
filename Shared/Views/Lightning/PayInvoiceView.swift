//
//  PayInvoiceView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

struct PayInvoiceView: View {
    @Binding var viewState: LightningRootView.ViewState
    @StateObject private var viewModel = PayInvoiceViewModel.config()
    
    var body: some View {
        VStack {
            ModalNavigationView(title: "Send Lightning Payment", backButtonAction: {
                viewState = .root
            })
            
            HStack(spacing: 4) {
                Text("You have")
                    .font(Font.mainFont())
                    .opacity(0.6)
                
                Text("\(viewModel.channelBalance) sat")
                    .font(Font.mainFont(size: 14))
            }
            .foregroundColor(Color.white)
            
            if let invoice = viewModel.invoice {
                if let network = viewModel.networkString {
                    HStack {
                        Text("Network:")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        
                        Text(network)
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightActiveLabel)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                if let amount = viewModel.amountString {
                    HStack {
                        Text("Amount:")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        
                        Text(amount)
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightActiveLabel)
                    }
                    .padding(.horizontal)
                }
                
                HStack {
                    Text("Description:")
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Spacer()
                    
                    Text("-")
                        .font(.mainFont(size: 14))
                        .foregroundColor(Color.lightActiveLabel)
                }
                .padding(.horizontal)
                
                if !invoice.is_expired(), let expires = viewModel.expires {
                    HStack {
                        Text("Expires:")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        
                        Text(expires)
                            .lineLimit(1)
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightActiveLabel)
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
                
                Spacer()
                
                Button("Send") {
                    print("SEND")
                    viewModel.send()
                }
                .modifier(PButtonEnabledStyle(enabled: $viewModel.sendButtonAvaliable))
                .disabled(!viewModel.sendButtonAvaliable)
                .padding()
                
            } else {
                HStack(spacing: 8) {
#if os(iOS)
                    TextField(String(), text: $viewModel.invoiceString)
                        .foregroundColor(Color.white)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.invoiceString.isEmpty,
                                placeholder: "Paste invoice..."
                            )
                        )
                        .frame(height: 20)
                        .keyboardType(.numberPad)
#else
                    TextField(String(), text: $viewModel.invoiceString)
                        .font(Font.mainFont(size: 16))
                        .foregroundColor(Color.white)
                        .modifier(
                            PlaceholderStyle(
                                showPlaceHolder: viewModel.invoiceString.isEmpty,
                                placeholder: "Paste invoice..."
                            )
                        )
                        .frame(height: 20)
                        .textFieldStyle(PlainTextFieldStyle())
#endif
                }
                .modifier(TextFieldModifierDark(cornerRadius: 26))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(true ? Color.clear : Color.red, lineWidth: 1)
                )
                .padding()
                
                Spacer()
            }
        }
        .alert(isPresented: $viewModel.sent) {
            Alert(
                title: Text("Sent"),
                message: Text(viewModel.amountString!),
                dismissButton: Alert.Button.default(
                    Text("Dismiss"), action: { }
                )
            )
        }

    }
}

struct SendLightningPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            PayInvoiceView(viewState: .constant(.send))
        }
    }
}
