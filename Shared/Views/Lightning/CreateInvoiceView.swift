//
//  CreateInvoiceView.swift
//  Portal
//
//  Created by farid on 6/6/22.
//

import SwiftUI

struct CreateInvoiceView: View {
    @StateObject var vm = CreateInvoiceViewModel()
    @Binding var viewState: LightningRootView.ViewState
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.portalBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                ModalNavigationView(title: "Create Invoice", backButtonAction: {
                    viewState = .root
                })
                .padding()
                
                if let code = vm.qrCode {
                    Image(nsImage: code)
                        .resizable()
                        .frame(width: 350, height: 350)
                        .cornerRadius(10)
                        .padding(.bottom)
                    
                    Group {
                        HStack {
                            Text("Amount:")
                                .font(.mainFont(size: 14))
                                .foregroundColor(Color.lightInactiveLabel)
                            
                            Spacer()
                            
                            Text("\(vm.satAmount) sat")
                                .font(.mainFont(size: 14))
                                .foregroundColor(Color.lightActiveLabel)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Description:")
                                .font(.mainFont(size: 14))
                                .foregroundColor(Color.lightInactiveLabel)
                            
                            Spacer()
                            
                            Text(vm.memo)
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
                        
                        if false {
                            HStack {
                                Text("Expires:")
                                    .font(.mainFont(size: 14))
                                    .foregroundColor(Color.lightInactiveLabel)
                                
                                Spacer()
                                
                                Text("\(vm.expires)")
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
                    }
                    
//                    Text("Invoice:")
//                        .font(.mainFont(size: 14))
//                        .foregroundColor(Color.lightInactiveLabel)
                    
                    Text("\(vm.invoiceString)")
                        .font(.mainFont(size: 12))
                        .foregroundColor(Color.white)
                        .padding()
                    
                    Spacer()
                    
                    PButtonDark(label: "Share", height: 40, fontSize: 16, enabled: true, action: {
                        vm.showShareSheet.toggle()
                    })
                    .padding()
//                    .sheet(isPresented: $vm.showShareSheet) {
//                        ShareSheet(activityItems: [vm.invoiceString])
//                    }
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
                            TextField(String(), text: $vm.satAmount)
                                .foregroundColor(Color.white)
                                .modifier(
                                    PlaceholderStyle(
                                        showPlaceHolder: vm.satAmount.isEmpty,
                                        placeholder: "0"
                                    )
                                )
                                .frame(height: 20)
                                .keyboardType(.numberPad)
                            #else
                            TextField(String(), text: $vm.satAmount)
                                .font(Font.mainFont(size: 16))
                                .foregroundColor(Color.white)
                                .modifier(
                                    PlaceholderStyle(
                                        showPlaceHolder: vm.satAmount.isEmpty,
                                        placeholder: "0"
                                    )
                                )
                                .frame(height: 20)
                                .textFieldStyle(PlainTextFieldStyle())
            //                    .disabled(isSendingMax)
                            #endif
                            
                            Text("sat")
                                .foregroundColor(Color.lightActiveLabelNew)
                                .font(Font.mainFont(size: 16))
                        }
                        .modifier(TextFieldModifierDark(cornerRadius: 26))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(true ? Color.clear : Color.red, lineWidth: 1)
                        )
                        
                        HStack(spacing: 2) {
                            Spacer()
                            Text(vm.fiatValue)
                                .font(Font.mainFont())
                                .foregroundColor(Color.lightActiveLabelNew)
                            
                            if !vm.fiatValue.isEmpty {
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
                            TextField(String(), text: $vm.memo)
                                .foregroundColor(Color.white)
                                .modifier(
                                    PlaceholderStyle(
                                        showPlaceHolder: $vm.memo.isEmpty,
                                        placeholder: "Description..."
                                    )
                                )
                                .frame(height: 20)
                                .keyboardType(.numberPad)
                            #else
                            TextField(String(), text: $vm.memo)
                                .font(Font.mainFont(size: 16))
                                .foregroundColor(Color.white)
                                .modifier(
                                    PlaceholderStyle(
                                        showPlaceHolder: vm.memo.isEmpty,
                                        placeholder: "Description..."
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
                        
                        DatePicker("Expire date", selection: $vm.expireDate, in: vm.pickerDateRange, displayedComponents: [.date, .hourAndMinute])
                            .font(Font.mainFont())
                            .foregroundColor(Color.lightActiveLabelNew)
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding(.vertical)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    PButtonDark(label: "Create", height: 40, fontSize: 16, enabled: true, action: {
                        vm.createInvoice()
                    })
                    .padding()
                }
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

