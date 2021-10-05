//
//  LocalStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation

final class LocalStorage: ILocalStorage {
    private let storage: UserDefaults
    private let appLaunchesCountKey = "APP_LAUNCHES_COUNTER"
    private let currentAccountIDKey = "CURRENT_WALLET_ID"
    private let syncedExchangesIDsKey = "SYNCED_EXCHANGES_IDS"
    private var appLaunchesCounter: Int {
        storage.integer(forKey: appLaunchesCountKey)
    }

    var currentAccountID: String?
    var isFirstLaunch: Bool {
        storage.integer(forKey: appLaunchesCountKey) == 0
    }
    var syncedExchangesIds: [String] {
        storage.object(forKey: syncedExchangesIDsKey) as? [String] ?? []
    }
        
    init() {
        storage = UserDefaults.standard
    }
    
    func incrementAppLaunchesCouner() {
        let counter = appLaunchesCounter
        storage.setValue(counter + 1, forKey: appLaunchesCountKey)
    }
    
    func getCurrentAccountID() -> String? {
        guard let uuidString = storage.string(forKey: currentAccountIDKey) else {
            return nil
        }
        return uuidString
    }
    
    func setCurrentAccountID(_ id: String) {
        storage.setValue(id, forKey: currentAccountIDKey)
    }
    
    func removeCurrentAccountID() {
        storage.removeObject(forKey: currentAccountIDKey)
    }
    
    func addSyncedExchange(id: String) {
        var exchangesIds = syncedExchangesIds
        
        if !exchangesIds.contains(id) {
            exchangesIds.append(id)
            storage.set(exchangesIds, forKey: syncedExchangesIDsKey)
        }
    }
    
    func removeSyncedExchange(id: String) {
        var exchangesIds = syncedExchangesIds
        
        if let index = exchangesIds.firstIndex(of: id) {
            exchangesIds.remove(at: index)
            storage.set(exchangesIds, forKey: syncedExchangesIDsKey)
        }
    }
}
