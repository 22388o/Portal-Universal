//
//  IBalanceAdapter.swift
//  Portal
//
//  Created by Farid on 13.07.2021.
//

import Foundation
import RxSwift

protocol IBalanceAdapter {
    var balanceState: AdapterState { get }
    var balanceStateUpdatedObservable: Observable<Void> { get }
    var balance: Decimal { get }
    var balanceLocked: Decimal? { get }
    var balanceUpdatedObservable: Observable<Void> { get }
}

extension IBalanceAdapter {
    var balanceLocked: Decimal? { nil }
}
