//
//  BinanceAssetInfo.swift
//  Portal
//
//  Created by Farid on 27.09.2021.
//

import Foundation

struct BinanceAssetInfo: Codable {
    let success: Bool
    let assetDetail: [String: BinanceAssetFeesInfo]?
}

struct BinanceAssetFeesInfo: Codable {
    let minWithdrawAmount: Double
    let depositStatus: Bool
    let withdrawFee: Double
    let withdrawStatus: Bool
    let depositTip: String?
}

struct BinanceNewOrderACK: Codable {
    let symbol: String
    let orderId: Int32
    let clientOrderId: String
    let transactTime: Int64
}

struct DepositAddressInfo: Codable {
    let address: String
}
