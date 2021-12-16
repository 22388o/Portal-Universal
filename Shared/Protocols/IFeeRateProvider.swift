//
//  IFeeRateProvider.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import Combine

protocol IFeeRateProvider {
    var feeRatePriorityList: [FeeRatePriority] { get }
    var defaultFeeRatePriority: FeeRatePriority { get }
    var recommendedFeeRate: Future<Int, Never> { get }
    func feeRate(priority: FeeRatePriority) -> Future<Int, Never>
}

extension IFeeRateProvider {

    var feeRatePriorityList: [FeeRatePriority] {
        [.recommended]
    }

    var defaultFeeRatePriority: FeeRatePriority {
        .recommended
    }

    func feeRate(priority: FeeRatePriority) -> Future<Int, Never> {
        if case let .custom(value, _) = priority {
            return Future { promisse in
                promisse(.success(value))
            }
        } else {
            return recommendedFeeRate
        }
    }

}
