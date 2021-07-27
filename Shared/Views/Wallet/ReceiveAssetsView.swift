//
//  ReceiveAssetsView.swift
//  Portal
//
//  Created by Farid on 19.04.2021.
//

import SwiftUI

class ReceiveAssetViewModel: ObservableObject {
    private let qrCodeProvider: IQRCodeProvider
    let receiveAddress: String
    
    @Published var qrCode: Image? = nil
    @Published var isCopied: Bool = false
    
    init(address: String) {
        receiveAddress = address
        qrCodeProvider = QRCodeProvider()
    }
    
    func update() {
        qrCode = qrCodeProvider.code(for: receiveAddress)
    }
}

extension ReceiveAssetViewModel {
    static func config(coin: Coin) -> ReceiveAssetViewModel {
        let walletManager = Portal.shared.walletManager
        let adapterManager = Portal.shared.adapterManager
        
        var address = String()
        
        if let wallet = walletManager.activeWallets.first(where: { $0.coin == coin }), let adapter = adapterManager.depositAdapter(for: wallet) {
            address = adapter.receiveAddress
        }
       
        return ReceiveAssetViewModel(address: address)
    }
}

struct ReceiveAssetsView: View {
    private let coin: Coin
    @ObservedObject private var viewModel: ReceiveAssetViewModel
    @ObservedObject private var state = Portal.shared.state
        
    init(coin: Coin) {
        self.coin = coin
        self.viewModel = ReceiveAssetViewModel.config(coin: coin)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 8)
                )
            
            coin.icon
                .resizable()
                .frame(width: 64, height: 64)
                .offset(y: -32)
            
            HStack {
                Spacer()
                PButton(bgColor: Color.doneButtonBg, label: "Done", width: 73, height: 32, fontSize: 12, enabled: true) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        state.receiveAsset.toggle()
                    }
                }
            }
            .padding([.top, .trailing], 16)
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("Receive \(coin.name)")
                        .font(.mainFont(size: 23))
                        .foregroundColor(Color.coinViewRouteButtonActive)
                }
                .padding(.top, 57)
                .padding(.bottom, 16)
                
                Divider()
                    .padding(.vertical)
                
                HStack {
                    if let image = viewModel.qrCode {
                        image
                            .resizable()
                            .frame(width: 128, height: 128)
                    }
                    VStack(alignment: .leading) {
                        Text("Address")
                            .font(.mainFont(size: 12))
                            .foregroundColor(Color.coinViewRouteButtonActive)
                        Text(viewModel.receiveAddress)
                            .font(.mainFont(size: 16))
                            .foregroundColor(Color.coinViewRouteButtonInactive)
                        HStack(spacing: 12) {
                            PButton(label: "Copy to clipboard", width: 140, height: 32, fontSize: 12, enabled: true) {
                                print("receiver address = \(viewModel.receiveAddress)")
                                UIPasteboard.general.string = viewModel.receiveAddress
                                
                                if viewModel.isCopied != true {
                                    withAnimation {
                                        viewModel.isCopied = true
                                    }
                                }
                            }
                            
                            if viewModel.isCopied {
                                Text("Copied to clipboard!")
                                    .font(.mainFont(size: 12))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    Spacer()
                }
                
                Divider()
                    .padding(.vertical)
            }
            .padding(.horizontal, 40)
        }
        .allowsHitTesting(true)
        .frame(width: 630, height: 310)
        .onAppear {
            viewModel.update()
        }
    }
}

struct ReceiveAssetsView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveAssetsView(coin: Coin.bitcoin())
            .frame(width: 576, height: 350)
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
