//
//  BitcoinFeeRateProvider.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import RxSwift
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

    var recommendedFeeRate: Single<Int> { feeRateProvider.bitcoinFeeRate(blockCount: mediumPriorityBlockCount) }

    var defaultFeeRatePriority: FeeRatePriority {
        .medium
    }

    func feeRate(priority: FeeRatePriority) -> Single<Int> {
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
            return Single.just(value)
        }
    }

}
