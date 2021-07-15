//
//  DBWallet+CoreDataClass.swift
//  Portal (iOS)
//
//  Created by Farid on 19.04.2021.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(DBWallet)
public class DBWallet: NSManagedObject, IWallet {
    var fiatCurrencyCode: String { fiatCurrency }
    var walletID: UUID { id }
    var assets: [IAsset] = []
        
    var key: String {
        "\(id.uuidString)-\(name)-seed"
    }
    
    var mnemonicDereviation: MnemonicDerivation {
        switch btcBipFormat {
        case 1:
            return .bip49
        case 2:
            return .bip84
        default:
            return .bip44
        }        
    }
    
    convenience init(model: NewWalletModel, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.id = UUID()
        self.name = model.name
        self.btcBipFormat = Int16(model.addressType.rawValue)
    }
    
    func setup(data: Data) -> Self {
        let coins = [
            Coin(type: .bitcoin, code: "BTC", name: "Bitcoin", color: Color.green, icon: Image("iconBtc")),
            Coin(type: .etherium, code: "ETH", name: "Ethereum", color: Color.blue, icon: Image("iconEth"))
        ]
                
        self.assets = coins.map {
            if $0.code == "BTC" {
                return Asset(coin: $0, walletID: walletID, data: data, bip: mnemonicDereviation)
            } else {
                return Asset(coin: $0, walletID: walletID, data: data)
            }
        }
        
        return self
    }
    
    func updateFiatCurrency(_ currency: FiatCurrency) {
        guard let contex = self.managedObjectContext else { return }
        fiatCurrency = currency.code
        try? contex.save()
    }
    
    func start() {
        stop()
        _ = assets.map { $0.adapter?.start() }
    }
    
    func stop() {
        _ = assets.map { $0.adapter?.stop() }
    }
}
