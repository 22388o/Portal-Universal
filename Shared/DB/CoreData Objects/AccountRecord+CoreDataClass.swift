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
        switch btcBipFormat {
        case 1:
            return MnemonicDerivation.bip49
        case 2:
            return MnemonicDerivation.bip84
        default:
            return MnemonicDerivation.bip44
        }
    }
    
    convenience init(id: String, name: String, bip: MnemonicDerivation, wordsKey: String?, saltKey: String?, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.id = id
        self.name = name
        self.btcBipFormat = Int16(bip.intValue)
        self.wordsKey = wordsKey
        self.saltKey = saltKey
    }
    
    func updateFiatCurrency(_ currency: FiatCurrency) {
        guard let contex = self.managedObjectContext else { return }
        fiatCurrency = currency.code
        try? contex.save()
    }
}
