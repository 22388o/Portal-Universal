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
            fatalError("Cannot config SendAssetViewModel")
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
                        TxFeesPicker(txFee: viewModel.txFee, txFeePriority: $viewModel.txFeePriority)
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
                }
                
                HStack {
                    if viewModel.step != .recipient {
                        PButton(label: "Back", width: 100, height: 44, fontSize: 12, enabled: true) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.goBack()
                            }
                        }
                        .transition(.opacity.combined(with: .scale))
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
                            }
                        }
                    }
                    .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
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
                }
                .padding([.horizontal, .bottom], 4)
            }
        })
        .alert(isPresented: $viewModel.showConfirmationAlert) {
            Alert(
                title: Text("Sent \(viewModel.exchangerViewModel.assetValue) \(viewModel.coin.code)"),
                message: Text("Reciever address: \(viewModel.receiverAddress)"), dismissButton: .default(Text("Dismiss"), action: {
                    Portal.shared.state.modalView = .none
            }))
        }
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

struct SendAssetProgressView: View {
    @Binding var step: SendAssetViewModel.SendAssetStep
    
    private var progress: CGFloat {
        switch step {
        case .recipient:
            return 0
        case .amount:
            return 200
        case .summary:
            return 400
        }
    }
    
    var body: some View {
        ZStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.coinViewRouteButtonInactive)
                    .frame(width: 400, height: 3)
                
                Rectangle()
                    .foregroundColor(Color.pButtonEnabledBackground)
                    .frame(width: progress, height: 3)
                    .animation(.linear(duration: 0.55))
            }
            
            HStack {
                Text("Recipient")
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .foregroundColor(Color.white)
                    .background(Color.pButtonEnabledBackground)
                    .cornerRadius(8)
                
                Spacer()
                
                Text("Amount")
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .foregroundColor(step == .amount || step == .summary ? Color.white : Color.coinViewRouteButtonActive)
                    .background(step == .amount || step == .summary ? Color.pButtonEnabledBackground : Color.coinViewRouteButtonInactive)
                    .cornerRadius(8)
                    .animation(.easeInOut(duration: 0.75))
                
                Spacer()
                
                Text("Summary")
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .foregroundColor(step == .summary ? Color.white : Color.coinViewRouteButtonActive)
                    .background(step == .summary ? Color.pButtonEnabledBackground : Color.coinViewRouteButtonInactive)
                    .cornerRadius(8)
                    .animation(.easeInOut(duration: 0.75))
                
            }
            .font(.mainFont(size: 10))
        }
    }
}

struct SendAssetProgressView_Previews: PreviewProvider {
    static var previews: some View {
        SendAssetProgressView(step: .constant(.summary))
            .frame(width: 400)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
