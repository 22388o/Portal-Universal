//
//  CreateInvoiceView.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import SwiftUI

struct CreateInvoiceView: View {
    @StateObject private var viewModel = CreateInvoiceViewModel.config()
    @Binding var viewState: LightningRootView.ViewState
    
    var body: some View {
        VStack {
            ModalNavigationView(title: "Create Invoice", backButtonAction: {
                viewState = .root
            })
            
            if let code = viewModel.qrCode, let invoice = viewModel.invoice {
                code
                    .resizable()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
                    .padding(.bottom)
                
                Group {
                    HStack {
                        Text("Amount:")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        
                        Text("\(viewModel.satAmount) sat")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightActiveLabel)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Description:")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        
                        Text(viewModel.memo)
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightActiveLabel)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Created:")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightInactiveLabel)
                        
                        Spacer()
                        
                        Text("\(Date())")
                            .lineLimit(1)
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.lightActiveLabel)
                    }
                    .padding(.horizontal)
                    
                    if !invoice.is_expired() {
                        HStack {
                            Text("Expires:")
                                .font(.mainFont(size: 14))
                                .foregroundColor(Color.lightInactiveLabel)
                            
                            Spacer()
                            
                            if let expireDate = viewModel.expires {
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
                }
                
                Text("\(viewModel.invoiceString)")
                    .font(.mainFont(size: 12))
                    .foregroundColor(Color.white)
                    .padding()
                
                Spacer()
                
                PButtonDark(label: "Copy to clipboard", height: 40, fontSize: 16, enabled: true, action: {
                    viewModel.copyToClipboard()
                })
                .padding()
                
            } else {
                VStack(alignment: .leading) {
                    Text("Amount")
                        .font(Font.mainFont())
                        .foregroundColor(Color.lightActiveLabelNew)

                    HStack(spacing: 8) {
                        Image("iconBtc")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        #if os(iOS)
                        TextField(String(), text: $viewModel.satAmount)
                            .foregroundColor(Color.white)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: viewModel.satAmount.isEmpty,
                                    placeholder: "0"
                                )
                            )
                            .frame(height: 20)
                            .keyboardType(.numberPad)
                        #else
                        TextField(String(), text: $viewModel.satAmount)
                            .font(Font.mainFont(size: 12))
                            .foregroundColor(Color.white)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: viewModel.satAmount.isEmpty,
                                    placeholder: "0"
                                )
                            )
                            .frame(height: 20)
                            .textFieldStyle(PlainTextFieldStyle())
        //                    .disabled(isSendingMax)
                        #endif
                        
                        Text("sat")
                            .foregroundColor(Color.lightActiveLabelNew)
                            .font(Font.mainFont(size: 12))
                    }
                    .modifier(TextFieldModifierDark(cornerRadius: 14))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 24)
//                            .stroke(true ? Color.clear : Color.red, lineWidth: 1)
//                    )
                    
                    HStack(spacing: 2) {
                        Spacer()
                        Text(viewModel.fiatValue)
                            .font(Font.mainFont())
                            .foregroundColor(Color.lightActiveLabelNew)
                        
                        if !viewModel.fiatValue.isEmpty {
                            Text("USD")
                                .font(Font.mainFont())
                                .foregroundColor(Color.lightActiveLabelNew)
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Description")
                        .font(Font.mainFont())
                        .foregroundColor(Color.lightActiveLabelNew)
                    
                    HStack(spacing: 8) {
                        #if os(iOS)
                        TextField(String(), text: $viewModel.memo)
                            .foregroundColor(Color.white)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: viewModel.memo.isEmpty,
                                    placeholder: "Description..."
                                )
                            )
                            .frame(height: 20)
                            .keyboardType(.numberPad)
                        #else
                        TextField(String(), text: $viewModel.memo)
                            .font(Font.mainFont(size: 12))
                            .foregroundColor(Color.white)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: viewModel.memo.isEmpty,
                                    placeholder: "Description..."
                                )
                            )
                            .frame(height: 20)
                            .textFieldStyle(PlainTextFieldStyle())
                        #endif
                    }
                    .modifier(TextFieldModifierDark(cornerRadius: 14))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 24)
//                            .stroke(true ? Color.clear : Color.red, lineWidth: 1)
//                    )
                    
                    DatePicker("Expire date", selection: $viewModel.expireDate, in: viewModel.pickerDateRange, displayedComponents: [.date, .hourAndMinute])
                        .font(Font.mainFont())
                        .foregroundColor(Color.lightActiveLabelNew)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding(.vertical)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                PButtonDark(label: "Create", height: 40, fontSize: 16, enabled: viewModel.createButtonAvaliable, action: {
                    viewModel.createInvoice()
                })
                .disabled(!viewModel.createButtonAvaliable)
                .padding()
            }
        }
    }
}

struct CreateInvoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            CreateInvoiceView(viewState: .constant(.fundChannel(LightningNode.sampleNodes[0])))
        }
        .frame(width: 500, height: 650)
    }
}

