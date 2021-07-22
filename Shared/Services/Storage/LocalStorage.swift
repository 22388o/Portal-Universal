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
    private var appLaunchesCounter: Int {
        storage.integer(forKey: appLaunchesCountKey)
    }

    var currentAccountID: String?
    var isFirstLaunch: Bool {
        storage.integer(forKey: appLaunchesCountKey) == 0
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
}
