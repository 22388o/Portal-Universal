//
//  TransactionRecord.swift
//  Portal
//
//  Created by Farid on 13.07.2021.
//

import Foundation
import Hodler

struct TransactionRecord {
    let uid: String
    let transactionHash: String
    let transactionIndex: Int
    let interTransactionIndex: Int
    let type: TransactionType
    let blockHeight: Int?
    let confirmationsThreshold: Int?
    let amount: Decimal
    let fee: Decimal?
    let date: Date
    let failed: Bool
    let from: String?
    let to: String?
    let lockInfo: TransactionLockInfo?
    let conflictingHash: String?
    let showRawTransaction: Bool
    let memo: String?

    func status(lastBlockHeight: Int?) -> TransactionStatus {
        if failed {
            return .failed
        } else if let blockHeight = blockHeight, let lastBlockHeight = lastBlockHeight {
            let threshold = self.confirmationsThreshold ?? 1
            let confirmations = lastBlockHeight - blockHeight + 1

            if confirmations >= threshold {
                return.completed
            } else {
                return .processing(progress: Double(confirmations) / Double(threshold))
            }
        }

        return .pending
    }

    func lockState(lastBlockTimestamp: Int?) -> TransactionLockState? {
        guard let lockInfo = lockInfo else {
            return nil
        }

        var locked = true

        if let lastBlockTimestamp = lastBlockTimestamp {
            locked = Double(lastBlockTimestamp) < lockInfo.lockedUntil.timeIntervalSince1970
        }

        return TransactionLockState(locked: locked, date: lockInfo.lockedUntil)
    }
    
    func confirmations(lastBlockHeight: Int?) -> Int {
        if let blockHeight = blockHeight, let lastBlockHeight = lastBlockHeight {
            return lastBlockHeight - blockHeight + 1
        } else {
            return 0
        }
    }

}

extension TransactionRecord: Comparable {

    public static func <(lhs: TransactionRecord, rhs: TransactionRecord) -> Bool {
        guard lhs.date == rhs.date else {
            return lhs.date < rhs.date
        }

        guard lhs.transactionIndex == rhs.transactionIndex else {
            return lhs.transactionIndex < rhs.transactionIndex
        }

        guard lhs.interTransactionIndex == rhs.interTransactionIndex else {
            return lhs.interTransactionIndex < rhs.interTransactionIndex
        }

        guard lhs.type == rhs.type else {
            return lhs.type < rhs.type
        }

        return lhs.uid < rhs.uid
    }

    public static func ==(lhs: TransactionRecord, rhs: TransactionRecord) -> Bool {
        lhs.uid == rhs.uid
    }

}

struct TransactionLockState {
    let locked: Bool
    let date: Date
}

extension TransactionLockState: Equatable {

    public static func ==(lhs: TransactionLockState, rhs: TransactionLockState) -> Bool {
        lhs.locked == rhs.locked && lhs.date == rhs.date
    }

}

struct TransactionLockInfo {
    let lockedUntil: Date
    let originalAddress: String

    init(lockedUntil: Date, originalAddress: String) {
        self.lockedUntil = lockedUntil
        self.originalAddress = originalAddress
    }

}
