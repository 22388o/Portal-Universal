//
//  ManageAssetViewModel.swift
//  Portal
//
//  Created by farid on 3/10/22.
//

import Foundation

class ManageAssetsViewModel: ObservableObject {
    let coinManager: ICoinManager
    let account: IAccount
    
    @Published var search = String()
    @Published var items = [Erc20ItemModel]()
    
    init(coinManager: ICoinManager, account: Account) {
        self.coinManager = coinManager
        self.account = account
        
        self.items = coinManager.avaliableCoins.map({ coin in
            let isInWallet = account.coins.first(where: { $0 == coin.code }) != nil
            return Erc20ItemModel(coin: coin, isInWallet: isInWallet)
        })
    }
}

extension ManageAssetsViewModel {
    static func config() -> ManageAssetsViewModel? {
        let manager = Portal.shared.coinManager
        
        guard
            let account = Portal.shared.accountManager.activeAccount
        else {
            return nil
        }
        
        return ManageAssetsViewModel(coinManager: manager, account: account)
    }
}

