//
//  IFeeRateProvider.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import RxSwift

protocol IFeeRateProvider {
    var feeRatePriorityList: [FeeRatePriority] { get }
    var defaultFeeRatePriority: FeeRatePriority { get }
    var recommendedFeeRate: Single<Int> { get }
    func feeRate(priority: FeeRatePriority) -> Single<Int>
}

extension IFeeRateProvider {

    var feeRatePriorityList: [FeeRatePriority] {
        [.recommended]
    }

    var defaultFeeRatePriority: FeeRatePriority {
        .recommended
    }

    func feeRate(priority: FeeRatePriority) -> Single<Int> {
        if case let .custom(value, _) = priority {
            return Single.just(value)
        }

        return recommendedFeeRate
    }

}
