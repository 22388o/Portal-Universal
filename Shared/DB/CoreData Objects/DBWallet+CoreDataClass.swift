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
    
    func setup(data: Data) {
//        assets = WalletMock().assets
//        return
        let sampleCoins = [
            Coin(code: "BTC", name: "Bitcoin", color: Color.green, icon: Image("iconBtc")),
            Coin(code: "BCH", name: "Bitcoin Cash", color: Color.gray, icon: Image("iconBch")),
            Coin(code: "ETH", name: "Ethereum", color: Color.yellow, icon: Image("iconEth")),
        ]
                
        self.assets = sampleCoins.prefix(5).map{ Asset(coin: $0, data: data) }
        
//        for _ in 5...Int.random(in: 6...10) {
//            let randomIndex = Int.random(in: 5...sampleCoins.count - 1)
//            let coin = sampleCoins[randomIndex]
//            let asset = Asset(coin: coin, data: data)
//            assets.append(asset)
//        }
    }
    
    func addTx(coin: Coin, amount: Decimal, receiverAddress: String, memo: String?) {
        guard let contex = self.managedObjectContext else { return }
        
        let tx = DBTx(context: contex)
        
        tx.txID = UUID().uuidString
        tx.amount = NSDecimalNumber(decimal: amount)
        tx.receiverAddress = receiverAddress
        tx.memo = memo
        tx.confirmations = 3
        tx.coin = coin.code
        tx.timestamp = Date()
        
        addToTxs(tx)
        
        try? contex.save()
    }
    
    func updateFiatCurrency(_ currency: FiatCurrency) {
        guard let contex = self.managedObjectContext else { return }
        let code = currency.code
        fiatCurrency = code
        try? contex.save()
    }
}
