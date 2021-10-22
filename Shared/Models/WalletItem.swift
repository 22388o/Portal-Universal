//
//  WalletItem.swift
//  Portal
//
//  Created by Farid on 20.07.2021.
//

import Foundation

struct WalletItem {
    let id: UUID = UUID()
    let viewModel: AssetItemViewModel
}

extension WalletItem: Hashable, Identifiable {
    public static func == (lhs: WalletItem, rhs: WalletItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(viewModel.coin.code)
        hasher.combine(viewModel.coin.name)
    }
}
