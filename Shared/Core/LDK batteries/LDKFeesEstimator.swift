//
//  LDKFeesEstimator.swift
//  Portal
//
//  Created by farid on 6/13/22.
//

#if os(iOS)
import LDKFramework
#elseif os(macOS)
import LDKFramework_Mac
#endif

class LDKFeesEstimator: FeeEstimator {
    override func get_est_sat_per_1000_weight(confirmation_target: LDKConfirmationTarget) -> UInt32 {
        return 253
    }
}

