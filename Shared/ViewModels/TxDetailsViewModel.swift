//
//  TxDetailsViewModel.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import Foundation

struct TxDetailsViewModel {
    let coin: Coin
    let transaction: TransactionRecord
    let lastBlockInfo: LastBlockInfo?
    
    var title: String {
        "\(transaction.type == .incoming ? "Received" : "Sent") \(transaction.amount.rounded(toPlaces: 6).toString()) \(coin.code)"
    }
    
    var date: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_us")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: transaction.date)
    }
    
    var from: String {
        "\(transaction.from ?? "Unknown")"
    }
    
    var to: String {
        "\(transaction.to ?? "Unknown")"
    }
    
    var txHash: String {
        "\(transaction.transactionHash)"
    }
    
    var amount: String {
        "\(transaction.amount.double) \(coin.code)"
    }
    
    var blockHeight: String {
        "\(transaction.blockHeight ?? 0) (\(transaction.confirmations(lastBlockHeight: lastBlockInfo?.height)) block confirmations)"
    }
    
    var networkFees: String {
        if let fee = transaction.fee {
            return "\(fee) \(coin.code)"
        } else {
            return " - "
        }
    }
    
    var completed: Bool {
        transaction.status(lastBlockHeight: lastBlockInfo?.height) == .completed
    }
    
    var explorerUrl: URL? {
        switch coin.type {
        case .bitcoin:
            return URL(string: "https://blockstream.info/testnet/tx/\(transaction.transactionHash)")
        case .ethereum:
            return URL(string: "https://ropsten.etherscan.io/tx/\(transaction.transactionHash)")
        default:
            return nil
        }
    }
}
