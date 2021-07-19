//
//  Wallet.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation

struct Wallet {
    let coin: Coin
    let account: Account

    init(coin: Coin, account: Account) {
        self.coin = coin
        self.account = account
    }
}

extension Wallet: Hashable {

    public static func ==(lhs: Wallet, rhs: Wallet) -> Bool {
        lhs.coin == rhs.coin && lhs.account == rhs.account
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(coin)
        hasher.combine(account)
    }

}
