//
//  Account.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import BitcoinKit
import EthereumKit

class Account: IAccount {
    let id: String
    let type: AccountType
    let mnemonicDereviation: MnemonicDerivation

    private(set) var name: String
    
    private let btcNetwork: Int
    private let ethNetwork: Int

    var confirmationsThreshold: Int
    var btcNetworkType: BitcoinKit.Kit.NetworkType
    var ethNetworkType: EthereumKit.NetworkType
    var fiatCurrencyCode: String
    var coins: [String]

    init(id: String, name: String, bip: MnemonicDerivation, type: AccountType) {
        self.id = id
        self.name = name
        self.type = type
        self.fiatCurrencyCode = "USD"
        self.mnemonicDereviation = bip
        self.btcNetwork = 1 //testNet
        self.ethNetwork = 1 //ropsten
        self.confirmationsThreshold = 0
        self.coins = ["BTC", "ETH"]

        switch btcNetwork {
        case 0:
            btcNetworkType = .mainNet
        case 2:
            btcNetworkType = .regTest
        default:
            btcNetworkType = .testNet
        }

        switch ethNetwork {
        case 0:
            ethNetworkType = .ethMainNet
        case 2:
            ethNetworkType = .kovan
        default:
            ethNetworkType = .ropsten
        }
    }
    
    init(record: AccountRecord, type: AccountType) {
        self.id = record.id
        self.name = record.name
        self.type = type
        self.fiatCurrencyCode = record.fiatCurrencyCode
        self.mnemonicDereviation = record.bip
        self.btcNetwork = Int(record.btcNetwork)
        self.ethNetwork = Int(record.ethNetwork)
        self.confirmationsThreshold = Int(record.confirmationThreshold)
        self.coins = !record.coins.isEmpty ? record.coins : ["BTC", "ETH"]
        
        switch btcNetwork {
        case 0:
            btcNetworkType = .mainNet
        case 2:
            btcNetworkType = .regTest
        default:
            btcNetworkType = .testNet
        }

        switch ethNetwork {
        case 0:
            ethNetworkType = .ethMainNet
        case 2:
            ethNetworkType = .kovan
        default:
            ethNetworkType = .ropsten
        }
    }
}

extension Account: Hashable {

    public static func ==(lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

class MockedAccount: IAccount {
    var id: String {
        UUID().uuidString
    }
    
    var name: String {
        "Mocked"
    }
    
    var type: AccountType {
        AccountType.mnemonic(words: [], salt: String())
    }
    
    var fiatCurrencyCode: String {
        "USD"
    }
    
    var mnemonicDereviation: MnemonicDerivation {
        MnemonicDerivation(rawValue: "bip44")!
    }
    
    var coins: [String] {
        ["BTC", "ETH"]
    }
}
