//
//  ReceiveAssetViewModel.swift
//  Portal
//
//  Created by Farid on 26.08.2021.
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
        qrCode = qrCodeProvider.code(for: receiveAddress)
        print("RECEIVE ADDRESS: \(receiveAddress)")
    }
    
    func update() {
        qrCode = qrCodeProvider.code(for: receiveAddress)
    }
    
    func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = receiveAddress
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(receiveAddress, forType: NSPasteboard.PasteboardType.string)
        #endif
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
