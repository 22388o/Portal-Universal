//
//  SendAssetView.swift
//  Portal
//
//  Created by Farid on 12.04.2021.
//

import SwiftUI

struct SendAssetView: View {
    @ObservedObject private var viewModel: SendAssetViewModel
        
    init(coin: Coin, currency: Currency) {
        guard let viewModel = SendAssetViewModel.config(coin: coin, currency: currency) else {
            fatalError("\(#function) Cannot config SendAssetViewModel")
        }
        self.viewModel = viewModel
    }
    
    var body: some View {
        ModalViewContainer(imageUrl: viewModel.coin.icon, size: CGSize(width: 567, height: 662), {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    VStack {
                        Text("Send \(viewModel.coin.name)")
                            .font(.mainFont(size: 23))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Text("Instantly send to any \(viewModel.coin.code) address")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.coinViewRouteButtonInactive)
                    }
                    
                    HStack(spacing: 4) {
                        Text("You have")
                            .foregroundColor(Color.coinViewRouteButtonInactive)
                        Text(viewModel.balanceString)
                            .foregroundColor(Color.orange)
                    }
                    .font(.mainFont(size: 12))
                }
                .padding(.top, 57)
                .padding(.bottom, 16)
                
                SendAssetProgressView(step: $viewModel.step)
                    .frame(width: 400)
                    .padding(8)
                
                switch viewModel.step {
                case .recipient:
                    VStack(alignment: .leading, spacing: 11) {
                        Text("Send to...")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonInactive)
                            .padding(.horizontal, 4)

                        PTextField(text: $viewModel.receiverAddress, placeholder: "Enter \(viewModel.coin.code) address", upperCase: false, width: 480, height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(viewModel.addressIsValid ? Color.clear : Color.red, lineWidth: 1)
                            )
                    }
                    .padding(.top, 17)
                    .padding(.bottom, 44)
                case .amount:
                    VStack(spacing: 12) {
                        ExchangerView(
                            viewModel: viewModel.exchangerViewModel,
                            isValid: $viewModel.amountIsValid,
                            isSendingMax: $viewModel.isSendingMax
                        )
                        TxFeesPicker(txFee: viewModel.txFee, showOptions: viewModel.coin == .bitcoin(), txFeePriority: $viewModel.txFeePriority)
                    }
                    .frame(width: 480)
                    .padding(.top, 14)
                    .padding(.bottom)
                case .summary:
                    Divider()
                        .padding(.vertical)

                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount:")
                                .foregroundColor(Color.coinViewRouteButtonInactive)
                            
                            Text("\(viewModel.amount.string) \(viewModel.coin.code) (\(viewModel.exchangerViewModel.fiatValue) \(viewModel.exchangerViewModel.currency.code))")
                                .foregroundColor(Color.coinViewRouteButtonActive)

                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recipient address:")
                                .foregroundColor(Color.coinViewRouteButtonInactive)

                            Text("\(viewModel.receiverAddress)")
                                .foregroundColor(Color.coinViewRouteButtonActive)

                        }

                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Network fees:")
                                .foregroundColor(Color.coinViewRouteButtonInactive)

                            Text(viewModel.txFee)
                                .foregroundColor(Color.coinViewRouteButtonActive)

                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Private description / memo (optional)")
                                .font(.mainFont(size: 12))
                                .foregroundColor(Color.coinViewRouteButtonInactive)

                            PTextField(text: $viewModel.memo, placeholder: "Enter private description or memo", upperCase: false, width: 480, height: 48)
                        }

                    }
                    .font(.mainFont(size: 12))
                    
                    Divider()
                        .padding(.vertical)
                case .sent:
                    if let error = viewModel.sendError {
                        VStack {
                            Text("Something went wrong :/")
                                .foregroundColor(Color.coinViewRouteButtonInactive)
                                .font(.mainFont(size: 16))
                            Text(error.localizedDescription)
                                .foregroundColor(Color.coinViewRouteButtonActive)
                                .font(.mainFont(size: 12))
                        }
                        .padding()
                    } else {
                        Divider()
                            .padding(.vertical)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tx sent!")
                                .foregroundColor(Color.coinViewRouteButtonInactive)
                                .font(.mainFont(size: 16))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Amount:")
                                    .foregroundColor(Color.coinViewRouteButtonInactive)
                                
                                Text("\(viewModel.amount.string) \(viewModel.coin.code) (\(viewModel.exchangerViewModel.fiatValue) \(viewModel.exchangerViewModel.currency.code))")
                                    .foregroundColor(Color.coinViewRouteButtonActive)

                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recipient address:")
                                    .foregroundColor(Color.coinViewRouteButtonInactive)

                                Text("\(viewModel.receiverAddress)")
                                    .foregroundColor(Color.coinViewRouteButtonActive)

                            }

                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Network fees:")
                                    .foregroundColor(Color.coinViewRouteButtonInactive)

                                Text(viewModel.txFee)
                                    .foregroundColor(Color.coinViewRouteButtonActive)

                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Private description / memo (optional)")
                                    .font(.mainFont(size: 12))
                                    .foregroundColor(Color.coinViewRouteButtonInactive)
                                
                                Text(viewModel.memo.isEmpty ? "-" : viewModel.memo)
                                    .foregroundColor(Color.coinViewRouteButtonActive)
                                    .font(.mainFont(size: 12))
                                
                                Rectangle()
                                    .frame(width: 480, height: 0)
                            }

                        }
                        .font(.mainFont(size: 12))
                        
                        Divider()
                            .padding(.vertical)
                    }
                }
                
                HStack {
                    if viewModel.step != .sent {
                        if viewModel.step != .recipient {
                            PButton(label: "Back", width: 100, height: 44, fontSize: 12, enabled: true) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.goBack()
                                }
                            }
                            .transition(AnyTransition.opacity.combined(with: .scale))
                            .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                        }
                        
                        PButton(label: viewModel.step != .summary ? "Continue" : "Send", width: 334, height: 48, fontSize: 14, enabled: viewModel.actionButtonEnabled) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                switch viewModel.step {
                                case .recipient:
                                    viewModel.step = .amount
                                case .amount:
                                    viewModel.step = .summary
                                case .summary:
                                    viewModel.send()
                                case .sent:
                                    break
                                }
                            }
                        }
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                    } else {
                        PButton(label: "Close", width: 334, height: 48, fontSize: 14, enabled: true) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.close()
                            }
                        }
                        .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                    }
                }
                .padding(.bottom, 40)
                
                HStack(spacing: 0) {
                    Text("Status")
                    Text("Amount")
                        .padding(.leading, 66)
                    Text("Sent to…")
                        .padding(.leading, 44)
                    Spacer()
                }
                .font(.mainFont(size: 12))
                .foregroundColor(Color.coinViewRouteButtonInactive)
                .frame(width: 480)

                Spacer().frame(height: 8)

                Divider()

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.exchangerFieldBackground)

                    if !viewModel.transactions.isEmpty {
                        ScrollView {
                            LazyVStack_(alignment: .leading, spacing: 0) {
                                ForEach(viewModel.transactions.sorted{ $0.date > $1.date }, id:\.transactionHash) { tx in
                                    VStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            HStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(tx.status(lastBlockHeight: viewModel.lastBlockInfo?.height) == .completed ? Color.orange : Color.gray)
                                                    .frame(width: 6, height: 6)
                                                Text(tx.status(lastBlockHeight: viewModel.lastBlockInfo?.height) == .completed ? "Complete" : "Pending")
                                                    .foregroundColor(.orange)
                                            }
                                            .padding(.leading, 4)

                                            Text("\(tx.amount.double) \(viewModel.coin.code)")
                                                .frame(width: 85)
                                                .padding(.leading, 30)
                                            Text("\(tx.to ?? "unknown address")")
                                                .lineLimit(1)
                                                .frame(width: 201)
                                                .padding(.leading, 15)
                                            Text(tx.date.timeAgoSinceDate(shortFormat: true))
                                                .frame(width: 80)
                                                .lineLimit(1)
                                                .padding(.leading, 28)
                                        }
                                        .font(.mainFont(size: 12))
                                    }
                                    .id(tx.transactionHash)
                                    .foregroundColor(.coinViewRouteButtonInactive)
                                    .frame(height: 30)
                                    .frame(maxWidth: .infinity)

                                    Divider()
                                }
                            }
                        }
                    } else {
                        Text("There are no transactions yet")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                    }
                }
                .padding([.horizontal, .bottom], 4)
            }
        })
    }
}

struct SendAssetView_Previews: PreviewProvider {
    static var previews: some View {
        SendAssetView(
            coin: Coin.bitcoin(),
            currency: .fiat(USD)
        )
            .frame(width: 576, height: 662)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
