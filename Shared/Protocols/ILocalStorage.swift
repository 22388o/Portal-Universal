//
//  ILocalStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation

protocol ILocalStorage {
    var isFirstLaunch: Bool { get }
    var currentWalletID: UUID? { get set }
    func incrementAppLaunchesCouner()
    func getCurrentWalletID() -> UUID?
    func setCurrentWalletID(_ uuid: UUID)
    func removeCurrentWalletID()
}
