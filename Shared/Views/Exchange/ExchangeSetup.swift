//
//  ExchangeSetup.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import SwiftUI
import Combine

struct ExchangeSetup: View {
    @ObservedObject var viewModel: ExchangeSetupViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.94))
                .padding(8)
            
            VStack(spacing: 0) {
                Text("Trade fast like a pro & bring back your gains in a snap.")
                    .multilineTextAlignment(.center)
                    .font(.mainFont(size: 30, bold: false))
                    .frame(width: 409)
                
                Text("Setup exchange - Step \(viewModel.step.description) of 2")
                    .font(.mainFont(size: 14, bold: false))
                    .padding(.top, 15)
                    .padding(.bottom, 8)
                
                Text("Which exchanges do you use or have an account in?")
                    .multilineTextAlignment(.center)
                    .font(.mainFont(size: 18, bold: false))
                    .frame(width: 250)
                    .padding(.bottom, 25)
                
                switch viewModel.step {
                case .first:
                    List(viewModel.exchanges) { exchange in
                        HStack {
                            AsyncImageView(url: exchange.icon) {
                                Image("dollarsign.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            .frame(width: 24, height: 24)
                            
                            Text(exchange.name)
                                .font(.mainFont(size: 18, bold: false))
                            
                            Spacer()
                            
                            if viewModel.selectedExchanges.first(where: { $0.id == exchange.id}) != nil {
                                Image("doneIconBig")
                            }
                        }
                        .frame(height: 48)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let index = viewModel.selectedExchanges.firstIndex(where: { $0.id == exchange.id }) {
                                viewModel.selectedExchanges.remove(at: index)
                            } else {
                                viewModel.selectedExchanges.append(exchange)
                            }
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .frame(width: 388, height: 244)
                    .padding(.bottom, 24)
                    
                    PButton(
                        bgColor: Color.green,
                        label: "Continue",
                        width: 263,
                        height: 64,
                        fontSize: 18,
                        enabled: !viewModel.selectedExchanges.isEmpty
                    ) {
                        viewModel.step = .second
                    }
                case .second:
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ForEach(viewModel.selectedExchanges) { exchange in
                                VStack(spacing: 0) {
                                    HStack {
                                        AsyncImageView(url: exchange.icon) {
                                            Image("dollarsign.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                        }
                                        .frame(width: 24, height: 24)
                                        
                                        Text(exchange.name)
                                            .font(.mainFont(size: 18, bold: false))
                                        
                                        Spacer()
                                        
                                        Divider()
                                            .frame(width: 3)
                                            .background(Color.green)
                                    }
                                    .padding(.leading, 20)
                                    .frame(width: 200, height: 48)
                                    
                                    Divider()
                                        .frame(width: 200, height: 1)
                                        .background(Color.gray)
                                }
                            }
                            
                            Text("Change exchanges")
                                .font(.mainFont(size: 14, bold: false))
                                .foregroundColor(Color.gray)
                                .padding(.top, 20)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.step = .first
                                }
                            
                            Spacer()
                        }
                        
                        ExchangeCredentialsView(exchange: viewModel.selectedExchanges[viewModel.currentExchangeIndex])
                            .offset(y: 21)
                    }
                    .frame(height: 244)
                    .padding(.bottom, 24)
                
                    Spacer()
                        .frame(height: 64)
                }
            }
            .foregroundColor(.gray)
        }
    }
}

struct ExchangeSetup_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeSetup(viewModel: ExchangeSetupViewModel.config())
//            .environment(\.managedObjectContext, PersistenceController.exchangesPreview.container.viewContext)
    }
}
