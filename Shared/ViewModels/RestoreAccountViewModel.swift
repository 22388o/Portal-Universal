//
//  RestoreAccountViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Combine
import Foundation

final class RestoreAccountViewModel: ObservableObject {
    private var anyCancellable = Set<AnyCancellable>()
    
    @Published private var seed = [String]()

    @Published private(set) var restoreReady = false
    @Published private(set) var btcAddressFormat = BtcAddressFormat.segwit.rawValue
    
    @Published var accountName = String()
    @Published var seedInput = String()
    @Published var secureField: Bool = true
    
    var seedData: Data? {
        return try? JSONSerialization.data(withJSONObject: seed, options: [])
    }
    
    var errorMessage: String {
         if accountName.isEmpty {
            return "Account name must be at least 1 symbols long"
        } else {
            let filteredSeedArray = seed.filter { $0.count >= 3 }
            return (filteredSeedArray.count == 12 || filteredSeedArray.count == 24) ? String() : "Invalid seed! Please try again."
        }
    }
    
    var account: Account {
        Account(id: UUID().uuidString, name: accountName, bip: mnemonicDereviation, type: .mnemonic(words: seed, salt: "salty_password"))
    }
    
    private var mnemonicDereviation: MnemonicDerivation {
        switch btcAddressFormat {
        case 1:
            return MnemonicDerivation.bip49
        case 2:
            return MnemonicDerivation.bip84
        default:
            return MnemonicDerivation.bip44
        }
    }
    
    init() {
        $accountName
            .sink(receiveValue: { [weak self] name in
                guard let self = self else { return }
                self.validateInputs(accountName: name, seedArray: self.seed)
            })
            .store(in: &anyCancellable)
        
        $seed
            .sink { [weak self] seedArray in
                guard let self = self else { return }
                self.validateInputs(accountName: self.accountName, seedArray: seedArray)
            }
            .store(in: &anyCancellable)
        
        $seedInput
            .sink { [weak self] input in
                self?.seed = input.split{ $0.isWhitespace }.map{ String($0)}
            }
            .store(in: &anyCancellable)
    }
    
    private func validateInputs(accountName: String, seedArray: [String]) {
        let filteredSeedArray = seedArray.filter { $0.count >= 3 }
        restoreReady = !accountName.isEmpty && (filteredSeedArray.count == 12 || filteredSeedArray.count == 24)
    }
}
