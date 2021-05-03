//
//  SendAssetView.swift
//  Portal
//
//  Created by Farid on 12.04.2021.
//

import SwiftUI

struct SendAssetView: View {
    private let coin: Coin

    @ObservedObject private var viewModel: ViewModel
    @Binding var presented: Bool
    
    @FetchRequest(
        entity: DBTx.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \DBTx.timestamp, ascending: false),
        ]
//        predicate: NSPredicate(format: "coin == %@", code)
    ) private var allTxs: FetchedResults<DBTx>
        
    init(wallet: IWallet, asset: IAsset, presented: Binding<Bool>) {
        self.coin = asset.coin
        self.viewModel = .init(wallet: wallet, asset: asset)
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

//                .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 2)
            
            viewModel.asset.coin.icon
                .resizable()
                .frame(width: 64, height: 64)
                .offset(y: -32)
            
            HStack {
                Spacer()
                PButton(label: "Done", width: 73, height: 32, fontSize: 12, enabled: true) {
                    withAnimation {
                        presented.toggle()
                    }
                }
            }
            .padding([.top, .trailing], 16)
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    VStack {
                        Text("Send \(viewModel.asset.coin.code)")
                            .font(.mainFont(size: 23))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Text("Instantly send to any \(viewModel.asset.coin.code) address")
                            .font(.mainFont(size: 14))
                            .foregroundColor(Color.coinViewRouteButtonInactive)
                    }
                    VStack {
                        Text("You have \(viewModel.asset.balanceProvider.balance(currency: .fiat(USD))) \(viewModel.asset.coin.code)")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonInactive)

                        Text("0.0000012 \(viewModel.asset.coin.code) tx fee - Normal Speed")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonInactive)

                    }
                }
                .padding(.top, 57)
                .padding(.bottom, 16)
                                
                VStack(spacing: 23) {
                    ExchangerView(viewModel: viewModel.exchangerViewModel)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Send to...")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonInactive)

                        PTextField(text: $viewModel.receiverAddress, placeholder: "Reciever address", upperCase: false, width: 480, height: 48)
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
                            Spacer().frame(height: 8)
                            
                            ForEach(allTxs.filter {$0.coin == coin.code}) { tx in
                                HStack(spacing: 0) {
                                    Text("• Done")
                                    Text("\(tx.amount ?? 0) \(tx.coin ?? "?")")
                                        .frame(width: 85)
                                        .padding(.leading, 40)
                                    Text("\(tx.receiverAddress ?? "unknown address")")
                                        .lineLimit(1)
                                        .frame(width: 201)
                                        .padding(.leading, 32)
                                    Text("\(tx.timestamp ?? Date())")
                                        .frame(width: 80)
                                        .lineLimit(1)
                                        .padding(.leading, 32)
                                }
                                .foregroundColor(.coinViewRouteButtonActive)
                                .padding(.vertical, 2)
                                .frame(maxWidth: .infinity)
                            }
                            .font(.mainFont(size: 12))
                        }
                    }
                }
                .padding([.horizontal, .bottom], 4)
            }
        }
        .frame(width: 576, height: 662)
    }
}

import Combine

extension SendAssetView {
    final class ViewModel: ObservableObject {
        @Published private var amount: Decimal = 0.0
        @Published private(set) var canSend: Bool = false
        
        @Published var receiverAddress = String()
        @Published var memo = String()
        
        @ObservedObject var exchangerViewModel: ExchangerViewModel
        
        let asset: IAsset
        let wallet: IWallet
        
        private var cancellable = Set<AnyCancellable>()
        
        init(wallet: IWallet, asset: IAsset) {
            print("send asset view model inited")
            self.wallet = wallet
            self.asset = asset
            self.exchangerViewModel = .init(asset: asset.coin, fiat: USD)
            
            exchangerViewModel.$assetValue
                .compactMap { Decimal(string: $0) }
                .assign(to: \.amount, on: self)
                .store(in: &cancellable)
            
            Publishers.CombineLatest($amount, $receiverAddress)
                .map { $0 > 0 && $1.count > 10 }
                .assign(to: \.canSend, on: self)
                .store(in: &cancellable)
        }
        
        deinit {
            print("send asset view model deinited")
        }
        
        func send() {
            print("amount = \(amount), address: \(receiverAddress), memo: \(memo)")
            wallet.addTx(coin: asset.coin, amount: amount, receiverAddress: receiverAddress, memo: memo)
            
            reset()
        }
        
        private func reset() {
            amount = 0
            receiverAddress = String()
            memo = String()
            
            exchangerViewModel.reset()
        }
    }
}

struct SendAssetView_Previews: PreviewProvider {
    static var previews: some View {
        SendAssetView(wallet: WalletMock(), asset: Asset.bitcoin(), presented: .constant(false))
            .frame(width: 576, height: 662)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
