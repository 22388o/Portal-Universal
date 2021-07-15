//
//  IWalletsService.swift
//  Portal
//
//  Created by Farid on 14.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI

protocol IWalletsService {
    var currentWallet: IWallet? { get }
    var wallets: [IWallet]? { get }
    
    func createWallet(model: NewWalletModel)
    func switchWallet(_ wallet: IWallet)
    func deleteWallet(_ wallet: DBWallet)
    func restoreWallet()
}
