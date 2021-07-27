//
//  ILocalStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation

protocol ILocalStorage {
    var isFirstLaunch: Bool { get }
    var currentAccountID: String? { get set }
    func incrementAppLaunchesCouner()
    func getCurrentAccountID() -> String?
    func setCurrentAccountID(_ id: String)
    func removeCurrentAccountID()
}
