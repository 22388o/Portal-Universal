//
//  LocalStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation

final class LocalStorage: ILocalStorage {
    private let storage: UserDefaults
    private let appLaunchesCountKey = "APP_LAUNCHES_COUNT"
    private let currentWalletIDKey = "CURRENT_WALLET_ID"
    private var appLaunchesCounter: Int {
        storage.integer(forKey: appLaunchesCountKey)
    }

    var currentWalletID: UUID?
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
    
    func getCurrentWalletID() -> UUID? {
        guard let uuidString = storage.string(forKey: currentWalletIDKey) else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }
    
    func removeCurrentWalletID() {
        storage.removeObject(forKey: currentWalletIDKey)
    }
    
    func setCurrentWalletID(_ uuid: UUID) {
        storage.setValue(uuid.uuidString, forKey: currentWalletIDKey)
    }
}
