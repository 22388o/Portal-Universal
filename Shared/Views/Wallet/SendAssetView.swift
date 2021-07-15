//
//  SendAssetView.swift
//  Portal
//
//  Created by Farid on 12.04.2021.
//

import SwiftUI

struct SendAssetView: View {
    private let asset: IAsset

    @ObservedObject private var viewModel: SendAssetViewModel
    @Binding var presented: Bool
    @State private var showConfirmationAlert: Bool = false
        
    init(wallet: IWallet, asset: IAsset, fiatCurrency: FiatCurrency, presented: Binding<Bool>) {
        self.asset = asset
        
        self.viewModel = .init(
            wallet: wallet,
            asset: asset,
            fiatCurrency: fiatCurrency,
            ticker: Portal.shared.marketDataProvider.ticker(coin: asset.coin)
        )
            
        self._presented = presented
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.7), lineWidth: 8)
                )
            
            viewModel.asset.coin.icon
                .resizable()
                .frame(width: 64, height: 64)
                .offset(y: -32)
            
            HStack {
                Spacer()
                PButton(bgColor: Color.doneButtonBg, label: "Done", width: 73, height: 32, fontSize: 12, enabled: true) {
                    withAnimation {
                        presented.toggle()
                    }
                }
            }
            .padding([.top, .trailing], 16)
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    VStack {
                        Text("Send \(viewModel.asset.coin.name)")
                            .font(.mainFont(size: 23))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Text("Instantly send to any \(viewModel.asset.coin.code) address")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.coinViewRouteButtonInactive)
                    }
                    VStack {
                        HStack(spacing: 4) {
                            Text("You have")
                                .foregroundColor(Color.coinViewRouteButtonInactive)
                            Text(viewModel.balanceString)
                                .foregroundColor(Color.orange)
                        }
                        .font(.mainFont(size: 12))
                        
                        if !viewModel.txFee.isEmpty {
                            Text(viewModel.txFee)
                                .font(.mainFont(size: 12))
                                .foregroundColor(Color.coinViewRouteButtonInactive)
                        } else {
                            Text("Validate the form to calculate transaction fee")
                                .font(.mainFont(size: 12))
                                .foregroundColor(Color.coinViewRouteButtonInactive)
                        }

                    }
                }
                .padding(.top, 57)
                .padding(.bottom, 16)
                                
                VStack(spacing: 23) {
                    ExchangerView(viewModel: viewModel.exchangerViewModel, isValid: $viewModel.amountIsValid)
            
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Send to...")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonInactive)

                        PTextField(text: $viewModel.receiverAddress, placeholder: "Reciever address", upperCase: false, width: 480, height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(viewModel.addressIsValid ? Color.clear : Color.red, lineWidth: 1)
                            )
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Private description / memo (optional)")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonInactive)

                        PTextField(text: $viewModel.memo, placeholder: "Enter private description or memo", upperCase: false, width: 480, height: 48)
                    }
                }
                                
                PButton(label: "Send", width: 334, height: 48, fontSize: 14, enabled: viewModel.canSend) {
                    viewModel.send()
                }
                .padding(.top, 16)
                .padding(.bottom, 27)
                
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
                    Rectangle()
                        .fill(Color.exchangerFieldBackground)
                    
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(viewModel.transactions.sorted{ $0.date > $1.date }, id:\.uid) { tx in
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        HStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(tx.status(lastBlockHeight: asset.transactionAdaper?.lastBlockInfo?.height) == .completed ? Color.orange : Color.gray)
                                                .frame(width: 6, height: 6)
                                            Text(tx.status(lastBlockHeight: asset.transactionAdaper?.lastBlockInfo?.height) == .completed ? "Complete" : "Pending")
                                                .foregroundColor(.orange)
                                        }
                                        .padding(.leading, 4)
                                        
                                        Text("\(tx.amount.double) \(asset.coin.code)")
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
                                    .padding(.vertical, 12)
                                    
                                    Divider()
                                }
                                .foregroundColor(.coinViewRouteButtonInactive)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding([.horizontal, .bottom], 4)
            }
        }
        .frame(width: 576, height: 662)
        .alert(isPresented: $showConfirmationAlert) {
            Alert(title: Text("Success"), message: Text("Transaction was sent!"), dismissButton: .default(Text("Awesome"), action: {
                withAnimation {
                    presented.toggle()
                }
            }))
        }
    }
}

struct SendAssetView_Previews: PreviewProvider {
    static var previews: some View {
        SendAssetView(
            wallet: WalletMock(),
            asset: Asset.bitcoin(),
            fiatCurrency: USD,
            presented: .constant(false)
        )
            .frame(width: 576, height: 662)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
