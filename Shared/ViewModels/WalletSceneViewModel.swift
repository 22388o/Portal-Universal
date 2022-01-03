//
//  WalletSceneViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Combine
import SwiftUI
import Foundation

final class WalletSceneViewModel: ObservableObject {
    @Published var walletName: String
    @Published var account: IAccount
    @Published var fiatCurrency: FiatCurrency

    @Published private(set) var fiatCurrencies: [FiatCurrency] = []
    
    init(account: IAccount, userCurrrency: FiatCurrency, allCurrencies: [FiatCurrency]) {
        print("WalletViewModel init")
        self.fiatCurrency = userCurrrency
        
        self.account = account
        self.walletName = account.name
        self.fiatCurrencies = allCurrencies
        
        print("wallet name: \(account.name)")                                
    }
    
    deinit {
//        print("WalletScene view model deinit")
    }
}
