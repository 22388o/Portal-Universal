//
//  RestoreAccountViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Combine
import Foundation

final class RestoreAccountViewModel: ObservableObject {
    private let seeedLength = 24
    private var anyCancellable = Set<AnyCancellable>()

    @Published var accountName = String()
    @Published var seed = [String]()
    @Published private(set) var restoreReady: Bool = false
    @Published var btcAddressFormat = BtcAddressFormat.segwit.rawValue
    
    var seedData: Data? {
        return try? JSONSerialization.data(withJSONObject: seed, options: [])
    }
    
    var errorMessage: String {
         if accountName.isEmpty {
            return "Account name must be at least 1 symbols long"
        } else {
            let filteredSeedArray = seed.filter { $0.count >= 3 }
            return filteredSeedArray.count != seeedLength ? "Invalid seed! Please try again." : String()
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
        for _ in 1...seeedLength {
            seed.append(String())
        }
        
        $accountName
            .sink(receiveValue: { [weak self] name in
                guard let self = self else { return }
                let filteredSeedArray = self.seed.filter { $0.count >= 3 }
                self.restoreReady = !name.isEmpty && filteredSeedArray.count == self.seeedLength
            })
            .store(in: &anyCancellable)
        
        $seed
            .sink { [weak self] seedArray in
                guard let self = self else { return }
                let filteredSeedArray = seedArray.filter { $0.count >= 3 }
                self.restoreReady = !self.accountName.isEmpty && filteredSeedArray.count == self.seeedLength
            }
            .store(in: &anyCancellable)
    }
}
