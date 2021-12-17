//
//  Enums.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import HdWalletKit

enum BtcAddressFormat: Int, CustomStringConvertible, CaseIterable {
    case legacy
    case segwit
    case nativeSegwit
    
    var description: String {
        get {
            switch self {
            case .legacy:
                return "Legacy"
            case .segwit:
                return "SegWit"
            case .nativeSegwit:
                return "Native SegWit"
            }
        }
    }
}

enum TxSpeed: Int, CustomStringConvertible, CaseIterable {
    case low
    case mid
    case fast
    
    var title: String {
        get {
            switch self {
            case .low:
                return "Low"
            case .mid:
                return "Mid"
            case .fast:
                return "Fast"
            }
        }
    }
    
    var description: String {
        get {
            switch self {
            case .low:
                return "Less than 24 hours"
            case .mid:
                return "Less than 2 hours"
            case .fast:
                return "Less than 20 minutes"
            }
        }
    }
}

enum MarketDataRange {
    case day, week, month, year
}

enum AssetMarketValueViewType {
    case portfolio, asset
}

enum Currency: Equatable {
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        lhs.symbol == rhs.symbol
    }
    
    case fiat(FiatCurrency)
    case btc
    case eth
    
    var symbol: String {
        switch self {
        case .fiat(let currency):
            return currency.symbol
        case .btc:
            return "₿"
        case .eth:
            return "Ξ"
        }
    }
    
    var code: String {
        switch self {
        case .fiat(let currency):
            return currency.code
        case .btc:
            return "BTC"
        case .eth:
            return "ETH"
        }
    }
    
    var name: String {
        switch self {
        case .fiat(let currency):
            return currency.name
        case .btc:
            return "Bitcoin"
        case .eth:
            return "Ethereum"
        }
    }
}

enum Timeframe: Int {
    case day, week, month, year
    
    func intervalString() -> String {
        switch self {
        case .day:
            return "1d"
        case .week:
            return "1w"
        case .month:
            return "1M"
        case .year:
            return "1y"
        }
    }
    
    func toString() -> String {
        let intervalString: String
        
        switch self {
        case .day:
            intervalString = "Day"
        case .week:
            intervalString = "Week"
        case .month:
            intervalString = "Month"
        case .year:
            intervalString = "Year"
        }
        return intervalString + " change"
    }
}

import LocalAuthentication

enum Device {

    //To check that device has secure enclave or not
    public static var hasSecureEnclave: Bool {
        return !isSimulator && hasBiometrics
    }

    //To Check that this is this simulator
    public static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR == 1
    }

    //Check that this device has Biometrics features available
    private static var hasBiometrics: Bool {

        //Local Authentication Context
        let localAuthContext = LAContext()
        var error: NSError?

        /// Policies can have certain requirements which, when not satisfied, would always cause
        /// the policy evaluation to fail - e.g. a passcode set, a fingerprint
        /// enrolled with Touch ID or a face set up with Face ID. This method allows easy checking
        /// for such conditions.
        var isValidPolicy = localAuthContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        guard isValidPolicy == true else {

            if #available(iOS 11, *) {

                if error!.code != LAError.biometryNotAvailable.rawValue {
                    isValidPolicy = true
                } else{
                    isValidPolicy = false
                }
            }
            else {
                if error!.code != LAError.touchIDNotAvailable.rawValue {
                    isValidPolicy = true
                }else{
                    isValidPolicy = false
                }
            }
            return isValidPolicy
        }
        return isValidPolicy
    }
}

enum AppError: Error {
    case noConnection
    case ethereum(reason: EthereumError)
    case wordsChecksum
    case addressInvalid
    case notSupportedByHodler
    case unknownError

    enum EthereumError: Error {
        case insufficientBalanceWithFee
        case executionReverted(message: String)
    }
}


extension AppError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .noConnection: return "alert.no_internet"
        case .ethereum(let reason):
            switch reason {
            case .insufficientBalanceWithFee: return "" // localized in modules
            case .executionReverted(let message): return "ethereum_transaction.error.reverted: \(message)"
            }
        case .wordsChecksum:
            return "restore.checksum_error"
        case .addressInvalid: return "send.error.invalid_address"
        case .notSupportedByHodler: return "send.hodler_error.unsupported_address"
        case .unknownError: return "Unknown Error"
        }

    }

}

enum DBStorageError: Error {
    case cannotFetchWallets(error: Error)
    case cannotCreateWallet(error: Error)
    case cannotDeleteWallet(error: Error)
    case cannotSaveContext(error: Error)
    case cannotGetContext
}

enum FeeRatePriority: Equatable {
    case low
    case medium
    case recommended
    case high
    case custom(value: Int, range: ClosedRange<Int>)

    var title: String {
        switch self {
        case .low: return "send.tx_speed_low"
        case .medium: return "send.tx_speed_recommended"
        case .recommended: return "send.tx_speed_recommended"
        case .high: return "send.tx_speed_high"
        case .custom: return "send.tx_speed_custom"
        }
    }

    static func ==(lhs: FeeRatePriority, rhs: FeeRatePriority) -> Bool {
        switch (lhs, rhs) {
        case (.low, .low): return true
        case (.medium, .medium): return true
        case (.recommended, .recommended): return true
        case (.high, .high): return true
        case (.custom, .custom): return true
        default: return false
        }
    }

}

enum AdapterState {
    case synced
    case syncing(progress: Int, lastBlockDate: Date?)
    case searchingTxs(count: Int)
    case notSynced(error: Error)

    var isSynced: Bool {
        switch self {
        case .synced: return true
        default: return false
        }
    }

}

extension AdapterState: Equatable {
    public static func ==(lhs: AdapterState, rhs: AdapterState) -> Bool {
        switch (lhs, rhs) {
        case (.synced, .synced): return true
        case (.syncing(let lProgress, let lLastBlockDate), .syncing(let rProgress, let rLastBlockDate)): return lProgress == rProgress && lLastBlockDate == rLastBlockDate
        case (.notSynced, .notSynced): return true
        default: return false
        }
    }
}

enum TransactionDataSortMode: String, CaseIterable {
    case shuffle
    case bip69

    var title: String {
        "settings_privacy.sorting_\(self)"
    }

    var description: String {
        "settings_privacy.sorting_\(self).description"
    }
}

enum ExchangeViewMode {
    case full, compactLeft, compactRight
}

enum HeaderSwitchState {
    case wallet, exchange, dex
}

enum MarketLimitSwitchState {
    case market, limit
}

enum ExchangeSelectorState {
    case merged, selected(exchange: ExchangeModel)
}


enum AssetViewRoute {
    case value, transactions, alerts
}

enum OrderBookRoute {
    case buy, sell
}

enum MyOrdersRoute {
    case open, history
}

enum AlertType {
    case worthMore(Coin), worthLess(Coin), incrases(Coin), discrases(Coin)
    
    var description: String {
        switch self {
        case .worthMore(let coin):
            return "1.0 \(coin.code) is worth more than..."
        case .worthLess(let coin):
            return "1.0 \(coin.code) is worth less than..."
        case .incrases(let coin):
            return "Value of \(coin.code) incrases by..."
        case .discrases(let coin):
            return "Value of \(coin.code) discrases by..."
        }
    }
}

enum TxSortState {
    case all, sent, received, swapped
    
    var description: String {
        switch self {
        case .all:
            return "All transactions"
        case .sent:
            return "Sent"
        case .received:
            return "Received"
        case .swapped:
            return "Swapped"
        }
    }
}

enum NetworkResponse: String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum _Result<String> {
    case success
    case failure(String)
}
enum AdapterError: Error {
    case wrongParameters
    case unsupportedAccount
}

enum TransactionType: Int, Equatable { case incoming, outgoing, sentToSelf, approve, transfer }

extension TransactionType: Comparable {

    public static func <(lhs: TransactionType, rhs: TransactionType) -> Bool {
        lhs.rawValue >= rhs.rawValue
    }

}

enum TransactionStatus {
    case failed
    case pending
    case processing(progress: Double)
    case completed
}

extension TransactionStatus: Equatable {

    public static func ==(lhs: TransactionStatus, rhs: TransactionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.pending, .pending): return true
        case (let .processing(lhsProgress), let .processing(rhsProgress)): return lhsProgress == rhsProgress
        case (.completed, .completed): return true
        default: return false
        }
    }

}

enum MnemonicDerivation: String, CaseIterable {
    case bip44
    case bip49
    case bip84

    var title: String {
        "\(addressType) - \(self.rawValue.uppercased())"
    }

    var addressType: String {
        switch self {
        case .bip44: return "Legacy"
        case .bip49: return "SegWit"
        case .bip84: return "Native SegWit"
        }
    }
    
    var intValue: Int {
        switch self {
        case .bip44: return 0
        case .bip49: return 1
        case .bip84: return 2
        }
    }

    func description(coinType: Coin.CoinType) -> String {
        var description = "coin_settings.derivation.description.\(self)"

        if let addressPrefix = addressPrefix(coinType: coinType) {
            let startsWith = "coin_settings.derivation.starts_with \(addressPrefix)"
            description += " (\(startsWith))"
        }

        return description
    }

    private func addressPrefix(coinType: Coin.CoinType) -> String? {
        switch coinType {
        case .bitcoin:
            switch self {
            case .bip44: return "1"
            case .bip49: return "3"
            case .bip84: return "bc1"
            }
        default:
            return nil
        }
    }

}


enum SyncMode: String {
    case fast
    case slow
    case new

    var title: String {
        switch self {
        case .fast: return "API"
        case .slow: return "sync_mode.from_blockchain"
        case .new: return ""
        }
    }

    var description: String {
        switch self {
        case .fast: return "settings_privacy.alert_sync.recommended"
        case .slow: return "settings_privacy.alert_sync.more_private"
        case .new: return ""
        }
    }

}

enum AccountType {
    case mnemonic(words: [String], salt: String)
    
    var mnemonicSeed: Data? {
        switch self {
        case let .mnemonic(words, salt): return Mnemonic.seed(mnemonic: words, passphrase: salt)
        }
    }
}
