//
//  DBWallet+CoreDataClass.swift
//  Portal
//
//  Created by Farid on 27.03.2021.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(DBWallet)
public class DBWallet: NSManagedObject, IWallet {
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
        assets = WalletMock().assets
        return
        let sampleCoins = [
            Coin(code: "BTC", name: "Bitcoin", color: Color.green, icon: Image("iconBtc")),
            Coin(code: "BCH", name: "Bitcoin Cash", color: Color.gray, icon: Image("iconBch")),
            Coin(code: "ETH", name: "Ethereum", color: Color.yellow, icon: Image("iconEth")),
            Coin(code: "XLM", name: "Stellar Lumens", color: Color.blue, icon: Image("iconXlm")),
            Coin(code: "XTZ", name: "Stellar Lumens", color: Color.red, icon: Image("iconXtz")),
            
            Coin(code: "ERZ", name: "Eeeeee", color: Color.yellow, icon: Image("iconEth")),
            Coin(code: "MFK", name: "EEEEEE", color: Color.blue, icon: Image("iconXlm")),
            Coin(code: "PED", name: "PPPPPPe", color: Color.red, icon: Image("iconXtz")),
            Coin(code: "LAS", name: "LaaaaaaS", color: Color.yellow, icon: Image("iconBtc")),
            Coin(code: "NDC", name: "Nnnnnnn D", color: Color.blue, icon: Image("iconBch")),
            Coin(code: "NCB", name: "NNNNNNNcf", color: Color.red, icon: Image("iconXtz"))
        ]
        
        self.assets = sampleCoins.prefix(5).map{ Asset(coin: $0, data: data) }
        
        for _ in 0...295 {
            let randomIndex = Int.random(in: 5...sampleCoins.count - 1)
            let coin = sampleCoins[randomIndex]
            let asset = Asset(coin: coin, data: data)
            assets.append(asset)
        }
    }
}
