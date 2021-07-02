//
//  PortalTx.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Foundation
import BitcoinCore

struct PortalTxInput {
    let mine: Bool
    let address: String?
    let value: Int?
    
    init(data: TransactionInputInfo) {
        self.mine = data.mine
        self.address = data.address
        self.value = data.value
    }
}

struct PortalTxOutput {
    let mine: Bool
    let changeOutput: Bool
    let value: Int
    let address: String?
    
    init(data: TransactionOutputInfo) {
        self.mine = data.mine
        self.changeOutput = data.changeOutput
        self.value = data.value
        self.address = data.address
    }
}

struct PortalTx {
    enum TxDestination {
        case incoming, outgoing, sentToSelf
    }
    let uid: String
    let transactionHash: String
    let inputs: [PortalTxInput]
    let outputs: [PortalTxOutput]
    let blockHeight: Int?
    let timestamp: Int
    let destination: TxDestination
    let amount: Decimal
    let confirmations: Int
    var fee: Decimal?
    let date: Date
    let failed: Bool
    let from: String?
    let to: String?
    
    let coinRate: Decimal = pow(10, 8)
    
    init(transaction: TransactionInfo, lastBlockInfo: BlockInfo?) {
        self.uid = transaction.uid
        self.transactionHash = transaction.transactionHash
        self.inputs = transaction.inputs.map{ PortalTxInput(data: $0) }
        self.outputs = transaction.outputs.map{ PortalTxOutput(data: $0) }
        self.blockHeight = transaction.blockHeight
        self.timestamp = transaction.timestamp
        
        if let lastBlockHeight = lastBlockInfo?.height, let height = blockHeight {
            self.confirmations = lastBlockHeight - height + 1
        } else {
            self.confirmations = 0
        }
        
        var myInputsTotalValue: Int = 0
        var myOutputsTotalValue: Int = 0
        var myChangeOutputsTotalValue: Int = 0
        var outputsTotalValue: Int = 0
        var allInputsMine = true

        var anyNotMineFromAddress: String?
        var anyNotMineToAddress: String?

        for input in transaction.inputs {
            if input.mine {
                if let value = input.value {
                    myInputsTotalValue += value
                }
            } else {
                allInputsMine = false
            }

            if anyNotMineFromAddress == nil, let address = input.address {
                anyNotMineFromAddress = address
            }
        }

        for output in transaction.outputs {
            guard output.value > 0 else {
                continue
            }

            outputsTotalValue += output.value

            if output.mine {
                myOutputsTotalValue += output.value
                if output.changeOutput {
                    myChangeOutputsTotalValue += output.value
                }
            }

            if anyNotMineToAddress == nil, let address = output.address, !output.mine {
                anyNotMineToAddress = address
            }
        }

        var amount = myOutputsTotalValue - myInputsTotalValue

        if allInputsMine, let fee = transaction.fee {
            amount += fee
        }

        if amount > 0 {
            destination = .incoming
        } else if amount < 0 {
            destination = .outgoing
        } else {
            amount = myOutputsTotalValue - myChangeOutputsTotalValue
            destination = .sentToSelf
        }
        
        self.amount = Decimal(abs(amount)) / coinRate
        self.date = Date(timeIntervalSince1970: Double(transaction.timestamp))
        self.failed = transaction.status == .invalid
        self.from = destination == .incoming ? anyNotMineFromAddress : nil
        self.to = destination == .outgoing ? anyNotMineToAddress : outputs.first(where: { $0.mine })?.address ?? nil
        self.fee = transaction.fee.map { Decimal($0) / coinRate }
    }
}
