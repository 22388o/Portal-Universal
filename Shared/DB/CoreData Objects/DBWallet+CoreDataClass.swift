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
        self.fiatCurrencyCode = "USD"
        
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
            Coin(code: "BTC", name: "Bitcoin", color: UIColor.green, icon: UIImage(imageLiteralResourceName: "iconBtc")),
            Coin(code: "BCH", name: "Bitcoin Cash", color: UIColor.gray, icon: UIImage(imageLiteralResourceName: "iconBch")),
            Coin(code: "ETH", name: "Ethereum", color: UIColor.yellow, icon: UIImage(imageLiteralResourceName: "iconEth")),
            Coin(code: "XLM", name: "Stellar Lumens", color: UIColor.blue, icon: UIImage(imageLiteralResourceName: "iconXlm")),
            Coin(code: "XTZ", name: "Stellar Lumens", color: UIColor.brown, icon: UIImage(imageLiteralResourceName: "iconXtz")),
            
            Coin(code: "ERZ", name: "Eeeeee", color: UIColor.yellow, icon: UIImage(imageLiteralResourceName: "iconEth")),
            Coin(code: "MFK", name: "EEEEEE", color: UIColor.blue, icon: UIImage(imageLiteralResourceName: "iconXlm")),
            Coin(code: "PED", name: "PPPPPPe", color: UIColor.brown, icon: UIImage(imageLiteralResourceName: "iconXtz")),
            Coin(code: "LAS", name: "LaaaaaaS", color: UIColor.yellow, icon: UIImage(imageLiteralResourceName: "iconBtc")),
            Coin(code: "NDC", name: "Nnnnnnn D", color: UIColor.blue, icon: UIImage(imageLiteralResourceName: "iconBch")),
            Coin(code: "NCB", name: "NNNNNNNcf", color: UIColor.brown, icon: UIImage(imageLiteralResourceName: "iconXtz"))
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
