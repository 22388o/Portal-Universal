//
//  IPriceAlertStorage.swift
//  Portal
//
//  Created by farid on 12/6/21.
//

import Foundation

protocol IPriceAlertStorage {
    func alerts(accountId: String, coin: String) -> [PriceAlert]
    func addAlert(_ model: PriceAlertModel)
    func deleteAlert(_ alert: PriceAlert)
}
