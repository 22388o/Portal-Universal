//
//  IWallet.swift
//  Portal
//
//  Created by Farid on 18.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

protocol IWallet {
    var walletID: UUID { get }
    var assets: [IAsset] { get }
}
