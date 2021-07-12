//
//  Enums.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

enum BtcAddressFormat: Int16, CustomStringConvertible, CaseIterable {
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

enum Currency {
    case fiat(_ currency: FiatCurrency)
    case btc
    case eth
    
    var symbol: String {
        switch self {
        case .fiat(let currency):
            return currency.symbol
        case .btc:
            return "BTC"
        case .eth:
            return "ETH"
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

enum PError: Error {
    case unknow
}

enum KitSyncState {
    case synced
    case syncing(progress: Int, lastBlockDate: Date?)
    case searchingTxs(count: Int)
    case notSynced(error: Error)
}

extension KitSyncState: Equatable {
    public static func ==(lhs: KitSyncState, rhs: KitSyncState) -> Bool {
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

enum WalletCreationSteps {
    case createWalletName, seed, test, confirmation
}

enum WalletSceneState {
    case full, walletPortfolio, walletAsset
}

enum Scenes {
    case wallet, swap
}

enum AssetViewRoute {
    case value, transactions, alerts
}

enum ValueCurrencySwitchState: Int {
    case fiat, btc, eth
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

enum NetworkError: Error, LocalizedError {
    case parsing
    case inconsistentBehavior
    case networkError
    
    var errorDescription: String? {
        return "Something went wrong, we will fix it!"
    }
}
