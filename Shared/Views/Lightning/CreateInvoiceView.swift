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
                ZStack {
                    Text("Create Invoice")
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
                            
                            Text("\(vm.exchangerViewModel.assetValue) sat")
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
                    
                    Button("Share") {
                        vm.showShareSheet.toggle()
                    }
                    .modifier(PButtonEnabledStyle(enabled: .constant(true)))
                    .padding()
//                    .sheet(isPresented: $vm.showShareSheet) {
//                        ShareSheet(activityItems: [vm.invoiceString])
//                    }
                } else {
                    VStack(alignment: .leading) {
                        Text("Amount")
                            .font(Font.mainFont())
                            .foregroundColor(Color.white)
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 8) {
                                Image("iconBtc")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                TextField("", text: $vm.exchangerViewModel.assetValue)
                                    .modifier(
                                        PlaceholderStyle(
                                            showPlaceHolder: vm.exchangerViewModel.assetValue.isEmpty,
                                            placeholder: "0"
                                        )
                                    )
                                    .frame(height: 20)
                                    .colorMultiply(.lightActiveLabel)
                                    .textFieldStyle(PlainTextFieldStyle())
                                
                                Text("sat")
                                    .foregroundColor(Color.lightActiveLabelNew)//.opacity(0.4)
                            }
                            .modifier(TextFieldModifier(cornerRadius: 26))
                            .font(Font.mainFont(size: 16))
                        }
                        
                        HStack(spacing: 2) {
                            Spacer()
                            Text(vm.fiatValue)
                                .font(Font.mainFont())
                                .foregroundColor(Color.lightActiveLabelNew)
                            if !vm.exchangerViewModel.fiatValue.isEmpty {
                                Text("USD")
                                    .font(Font.mainFont())
                                    .foregroundColor(Color.lightActiveLabelNew)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("Description")
                            .font(Font.mainFont())
                            .foregroundColor(Color.lightActiveLabelNew)
                        
                        TextField("", text: $vm.memo)
                            .modifier(
                                PlaceholderStyle(
                                    showPlaceHolder: vm.memo.isEmpty,
                                    placeholder: "Description..."
                                )
                            )
                            .frame(height: 20)
                            .colorMultiply(.lightActiveLabel)
                            .textFieldStyle(PlainTextFieldStyle())
                            .modifier(TextFieldModifier(cornerRadius: 26))
                        
                        HStack {
                            Text("Expires:")
                                .font(Font.mainFont())
                                .foregroundColor(Color.white)

                            Text("\(vm.expireDate)")
                                .lineLimit(1)
                                .font(Font.mainFont())
                                .foregroundColor(Color.lightActiveLabelNew)
                        }
                        .padding(.vertical)
                        
                        DatePicker("Expire date", selection: $vm.expireDate, in: vm.pickerDateRange, displayedComponents: [.date, .hourAndMinute])
                            .font(Font.mainFont())
                            .foregroundColor(Color.white)
//                            .datePickerStyle(WheelDatePickerStyle())
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("Create") {
                        vm.createInvoice()
                    }
                    .modifier(PButtonEnabledStyle(enabled: .constant(true)))
                    .padding()
                }
            }
            .padding()
            .onReceive(vm.exchangerViewModel.$fiatValue, perform: { value in
                vm.fiatValue = value
            })
        }
    }
}

struct CreateInvoiceView_Previews: PreviewProvider {
    static var previews: some View {
        CreateInvoiceView(viewState: .constant(.fundChannel))
            .frame(width: 500, height: 650)
            .padding()
    }
}

