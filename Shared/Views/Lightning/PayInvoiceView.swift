//
//  PayInvoiceView.swift
//  Portal
//
//  Created by farid on 6/10/22.
//

import SwiftUI

struct PayInvoiceView: View {
    @Binding var viewState: LightningRootView.ViewState
    @StateObject private var viewModel = PayInvoiceViewModel()
    
    var body: some View {
        ZStack {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            
                VStack {
                    ModalNavigationView(title: "Send Lightning Payment", backButtonAction: {
                        viewState = .root
                    })
                    .padding()
                    
//                    HStack {
//                        Text("You have")
//                            .font(Font.mainFont())
//                            .opacity(0.6)
//
//                        Text("\(self.viewModel.channelBalance) sat")
//                            .font(Font.mainFont(size: 14))
//                    }
//                    .foregroundColor(Color.white)
                    
                    
//                    if viewModel.invoice != nil {
//                        HStack {
//                            Text("Network:")
//                                .font(.mainFont(size: 14))
//                                .foregroundColor(Color.lightInactiveLabel)
//
//                            Spacer()
//
//                            Text(viewModel.networkString!)
//                                .font(.mainFont(size: 14))
//                                .foregroundColor(Color.lightActiveLabel)
//                        }
//                        .padding(.horizontal)
//                        .padding(.top)
//
//                        HStack {
//                            Text("Amount:")
//                                .font(.mainFont(size: 14))
//                                .foregroundColor(Color.lightInactiveLabel)
//
//                            Spacer()
//
//                            Text(viewModel.amountString!)
//                                .font(.mainFont(size: 14))
//                                .foregroundColor(Color.lightActiveLabel)
//                        }
//                        .padding(.horizontal)
//
//                        HStack {
//                            Text("Description:")
//                                .font(.mainFont(size: 14))
//                                .foregroundColor(Color.lightInactiveLabel)
//
//                            Spacer()
//
//                            Text("-")
//                                .font(.mainFont(size: 14))
//                                .foregroundColor(Color.lightActiveLabel)
//                        }
//                        .padding(.horizontal)
//
//                        if !viewModel.invoice!.is_expired() {
//                            HStack {
//                                Text("Expires:")
//                                    .font(.mainFont(size: 14))
//                                    .foregroundColor(Color.lightInactiveLabel)
//
//                                Spacer()
//
//                                Text(viewModel.expires!)
//                                    .lineLimit(1)
//                                    .font(.mainFont(size: 14))
//                                    .foregroundColor(Color.lightActiveLabel)
//                            }
//                            .padding(.horizontal)
//                        } else {
//                            HStack {
//                                Text("Status:")
//                                    .font(.mainFont(size: 14))
//                                    .foregroundColor(Color.lightInactiveLabel)
//
//                                Spacer()
//
//                                Text("Expired")
//                                    .font(.mainFont(size: 14))
//                                    .foregroundColor(Color.lightActiveLabel)
//                            }
//                            .padding(.horizontal)
//                        }
//
//                        Spacer()
//
//                        if !viewModel.invoice!.is_expired() {
//                            Button("Send") {
//                                print("SEND")
//                                viewModel.send()
//                            }
//                            .modifier(PButtonEnabledStyle(enabled: .constant(true)))
//                        }
//                    } else {
//                        Spacer().frame(height: 15)
//
//                        Text("Scan QR code")
//                            .font(Font.mainFont())
//                            .opacity(0.6)
//
//                        Spacer().frame(height: 15)
//
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 8)
//                                .frame(width: 350, height: 350)
//                            Button("Scan") {
//                                viewModel.scan()
//                            }
//                            .modifier(PButtonEnabledStyle(enabled: .constant(true)))
//                            .frame(width: 80)
//                        }
//
//                        Spacer().frame(height: 15)
//
//                        Text("Or")
//                            .font(Font.mainFont())
//                            .opacity(0.6)
                        
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
//        }
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
