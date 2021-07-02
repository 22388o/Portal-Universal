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
    var fiatCurrencyCode: String {
        fiatCurrency
    }
    
    var walletID: UUID {
        id
    }
    
    var assets: [IAsset] = []
        
    var key: String {
        "\(id.uuidString)-\(name)-seed"
    }
    
    convenience init(model: NewWalletModel, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = model.id
        self.name = model.name
        
        context.insert(self)
        
        do {
            try context.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func setup(seed: [String], isNewWallet: Bool) -> Self {
        let sampleCoins = [
            Coin(code: "BTC", name: "Bitcoin", color: Color.green, icon: Image("iconBtc"))
//            Coin(code: "BCH", name: "Bitcoin Cash", color: Color.gray, icon: Image("iconBch")),
//            Coin(code: "ETH", name: "Ethereum", color: Color.yellow, icon: Image("iconEth")),
        ]
                
        self.assets = sampleCoins.map{ Asset(coin: $0, walletID: walletID, seed: seed, isNew: isNewWallet) }
        
        return self
    }
    
    func updateFiatCurrency(_ currency: FiatCurrency) {
        guard let contex = self.managedObjectContext else { return }
        let code = currency.code
        fiatCurrency = code
        try? contex.save()
    }
}
