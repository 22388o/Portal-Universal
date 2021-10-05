//
//  ExchangeBalanceInfo.swift
//  Portal
//
//  Created by Farid on 27.09.2021.
//

import Foundation

struct ExchangeBalanceInfo: Decodable {
    let makerCommission: Int
    let takerCommission: Int
    let buyerCommission: Int
    let sellerCommission: Int
    let updateTime: Int
    let canTrade: Bool
    let canWithdraw: Bool
    let canDeposit: Bool
    var balances: [ExchangeBalanceModel]
    
    enum Keys: String, CodingKey {
        case makerCommission
        case takerCommission
        case buyerCommission
        case sellerCommission
        case updateTime
        case canTrade
        case canWithdraw
        case canDeposit
        case balances
    }
}

extension ExchangeBalanceInfo {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        makerCommission = try container.decode(Int.self, forKey: .makerCommission)
        takerCommission = try container.decode(Int.self, forKey: .takerCommission)
        buyerCommission = try container.decode(Int.self, forKey: .buyerCommission)
        sellerCommission = try container.decode(Int.self, forKey: .sellerCommission)
        updateTime = try container.decode(Int.self, forKey: .updateTime)
        canTrade =  try container.decode(Bool.self, forKey: .canTrade)
        canWithdraw = try container.decode(Bool.self, forKey: .canWithdraw)
        canDeposit = try container.decode(Bool.self, forKey: .canDeposit)
        let balancesModels = try container.decode([BinanceBalance].self, forKey: .balances).filter{$0.free != "0.00000000"}
        balances = balancesModels.map{ ExchangeBalanceModel($0) }
    }
}
