//
//  BitcoinFeeRateProvider.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import Combine
import FeeRateKit

class BitcoinFeeRateProvider: IFeeRateProvider {
    private let feeRateProvider: FeeRateProvider
    private let lowPriorityBlockCount = 40
    private let mediumPriorityBlockCount = 8
    private let highPriorityBlockCount = 2

    init(feeRateProvider: FeeRateProvider) {
        self.feeRateProvider = feeRateProvider
    }

    var feeRatePriorityList: [FeeRatePriority] {
        [
            .low,
            .medium,
            .high,
            .custom(value: 1, range: 1...200)
        ]
    }

    var recommendedFeeRate: Future<Int, Never> {
        feeRateProvider.bitcoinFeeRate(blockCount: mediumPriorityBlockCount)
    }

    var defaultFeeRatePriority: FeeRatePriority {
        .medium
    }

    func feeRate(priority: FeeRatePriority) -> Future<Int, Never> {
        switch priority {
        case .low:
            return feeRateProvider.bitcoinFeeRate(blockCount: lowPriorityBlockCount)
        case .medium:
            return feeRateProvider.bitcoinFeeRate(blockCount: mediumPriorityBlockCount)
        case .high:
            return feeRateProvider.bitcoinFeeRate(blockCount: highPriorityBlockCount)
        case .recommended:
            return feeRateProvider.bitcoinFeeRate(blockCount: mediumPriorityBlockCount)
        case let .custom(value, _):
            return Future { promisse in promisse(.success(value))}
        }
    }

}
