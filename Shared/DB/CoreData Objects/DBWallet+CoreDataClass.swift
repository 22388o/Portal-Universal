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
public class DBWallet: NSManagedObject {
    var fiatCurrencyCode: String { fiatCurrency }
    
    var bip: String {
        switch btcBipFormat {
        case 1:
            return "bip49"
        case 2:
            return "bip84"
        default:
            return "bip44"
        }
    }
    
    convenience init(model: NewWalletModel, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.id = UUID()
        self.name = model.name
        self.btcBipFormat = Int16(model.addressType.rawValue)
    }
    
    func updateFiatCurrency(_ currency: FiatCurrency) {
        guard let contex = self.managedObjectContext else { return }
        fiatCurrency = currency.code
        try? contex.save()
    }
}
