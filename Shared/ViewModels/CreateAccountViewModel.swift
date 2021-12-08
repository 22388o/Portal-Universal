//
//  CreateAccountViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Combine
import HdWalletKit

final class CreateAccountViewModel: ObservableObject {
    enum Step {
        case name, seed, test, confirmation
    }
    
    @Published var step: Step = .name
    @Published var walletName = String()
    @Published var btcAddressFormat = BtcAddressFormat.segwit.rawValue
    @Published var test: SeedTestViewModel
    
    @Published private(set) var nameIsValid: Bool = false
    
    private var cancalable: AnyCancellable?
    
    private var type: AccountType
    
    init(type: AccountType) {
        self.type = type
        
        switch type {
        case .mnemonic(let words, _):
            self.test = SeedTestViewModel(seed: words)
        }
        
        cancalable = $walletName.sink { [weak self] name in
            self?.nameIsValid = !name.isEmpty
        }
    }
    
    deinit {
//        print("\(#function) deinit")
    }
    
    var account: Account {
        Account(id: UUID().uuidString, name: walletName, bip: mnemonicDereviation, type: type)
    }
    
    func formattedIndexString(_ index: Int) -> String {
        switch index {
        case 1:
            return "1st word"
        case 2:
            return "2nd word"
        case 3:
            return "3rd word"
        case 21:
            return "21st word"
        case 22:
            return "22nd word"
        case 23:
            return "23rd word"
        default:
            return "\(index)th word"
        }
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

    static func mnemonicAccountType() -> AccountType {
        let words = try! Mnemonic.generate(wordCount: .twentyFour, language: .english)
        return .mnemonic(words: words, salt: "salty_password")
    }
}
