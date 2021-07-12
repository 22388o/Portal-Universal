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
        
        self.id = UUID()
        self.name = model.name
        
        context.insert(self)
        
        do {
            try context.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func setup(seed: [String]) -> Self {
        let coins = [
            Coin(type: .bitcoin, code: "BTC", name: "Bitcoin", color: Color.green, icon: Image("iconBtc"))
        ]
                
        self.assets = coins.map{ Asset(coin: $0, walletID: walletID, seed: seed) }
        
        return self
    }
    
    func updateFiatCurrency(_ currency: FiatCurrency) {
        guard let contex = self.managedObjectContext else { return }
        let code = currency.code
        fiatCurrency = code
        try? contex.save()
    }
    
    func stop() {
        _ = assets.map { $0.kit?.stop() }
    }
}
