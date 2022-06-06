//
//  LightningRootView.swift
//  Portal
//
//  Created by farid on 6/2/22.
//

import SwiftUI

struct LightningRootView: View {
    @StateObject var vm = LightningViewViewModel.config()
    
    var body: some View {
        ModalViewContainer(size: CGSize(width: 500, height: 650), {
            ZStack(alignment: .top) {
                Color.portalBackground.edgesIgnoringSafeArea(.all)
                    .onAppear {
                        vm.refreshPayments()
                    }
                
                switch vm.viewState {
                case .root:
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
                                        vm.viewState = .manage
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
                                
                                Text(vm.onChainBalanceString)
                                    .font(.mainFont(size: 14))
                                    .foregroundColor(Color.lightActiveLabel)
                            }
                            
                            HStack {
                                Text("Lightning")
                                    .font(.mainFont(size: 14))
                                    .foregroundColor(Color.lightInactiveLabel)
                                
                                Spacer()
                                
                                Text(vm.channelsBalanceString)
                                    .font(.mainFont(size: 14))
                                    .foregroundColor(Color.lightActiveLabel)
                            }
                            
                            HStack {
                                Button("Receive") {
                                    vm.viewState = .createInvoice
                                }
                                .modifier(PButtonEnabledStyle(enabled: .constant(true)))
                                Button("Send") {
                                    vm.payInvoice.toggle()
                                }
                                .modifier(PButtonEnabledStyle(enabled: .constant(true)))
                            }
                            .sheet(isPresented: $vm.createInvoice, onDismiss: {
                                vm.refreshPayments()
                            }, content: {
                                //CreateInvoiceView()
                            })
                            .sheet(isPresented: $vm.payInvoice, onDismiss: {
                                vm.refreshPayments()
                            }, content: {
                                //PayInvoiceView()
                            })
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
                        
                        if !vm.payments.isEmpty {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(vm.payments) { payment in
                                        LightningPaymentItemView(payment: payment)
                                            .onTapGesture {
                                                guard payment.state == .requested else { return }
                                                vm.selectedPayment = payment
                                                vm.showActivityDetails.toggle()
                                            }
                                    }
                                    .frame(height: 80)
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .sheet(isPresented: $vm.showActivityDetails) {
                                        ///ActivityDetailsView(activity: vm.selectedPayment!)
                                    }
                                }
                            }
                        } else {
                            Spacer()
                            Text("There is no activity.")
                                .font(.mainFont(size: 14))
                                .foregroundColor(Color.lightActiveLabel)
                            Spacer()
                        }
                    }
                case .manage:
                    ManageChannelsView(viewState: $vm.viewState)
                case .openChannel:
                    OpenNewChannelView(viewModel: ChannelsViewModel(), viewState: $vm.viewState)
                case .createInvoice:
                    CreateInvoiceView(viewState: $vm.viewState)
                case .fundChannel:
                    EmptyView()
                }
            }
        })
    }
}

struct LightningRootView_Previews: PreviewProvider {
    static var previews: some View {
        LightningRootView()
    }
}
