//
//  EthereumFeeRateProvider.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import RxSwift
import Combine
import FeeRateKit

class EthereumFeeRateProvider: IFeeRateProvider {
    private let lower = 1_000_000_000
    private let upper = 400_000_000_000

    private let feeRateProvider: FeeRateProvider

    init(feeRateProvider: FeeRateProvider) {
        self.feeRateProvider = feeRateProvider
    }

    var recommendedFeeRate: Future<Int, Never> { feeRateProvider.ethereumGasPrice }
    var feeRatePriorityList: [FeeRatePriority] {
        [.recommended, .custom(value: lower, range: lower...upper)]
    }
}
