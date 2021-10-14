//
//  AccountRecord+CoreDataClass.swift
//  
//
//  Created by Farid on 19.07.2021.
//
//

import Foundation
import CoreData

@objc(AccountRecord)
public class AccountRecord: NSManagedObject {
    var fiatCurrencyCode: String { fiatCurrency }
    
    var bip: MnemonicDerivation {
        MnemonicDerivation.bip84
    }
    
    convenience init(id: String, name: String, bip: MnemonicDerivation, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.id = id
        self.name = name
        self.btcBipFormat = Int16(bip.intValue)
    }
    
    func updateFiatCurrency(_ currency: FiatCurrency) {
        guard let contex = self.managedObjectContext else { return }
        fiatCurrency = currency.code
        try? contex.save()
    }
}
