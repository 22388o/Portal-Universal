//
//  IAccount.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation

protocol IAccount {
    var id: String { get }
    var name: String { get }
    var type: AccountType { get }
    var fiatCurrencyCode: String { get }
    var mnemonicDereviation: MnemonicDerivation { get }
    var coins: [String] { get }
}
