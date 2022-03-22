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
    
    @Published var step = Step.name
    @Published var accountName = String()
    @Published var isUsingStrongSeed = false
    @Published var btcAddressFormat = BtcAddressFormat.segwit.rawValue
    @Published var test: SeedTestViewModel
    @Published private(set) var nameIsValid = false
    
    private var cancalable: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    
    private var type: AccountType
    
    init(type: AccountType) {
        self.type = type
        
        switch type {
        case .mnemonic(let words, _):
            self.test = SeedTestViewModel(seed: words)
        }
        
        cancalable = $accountName.sink { [weak self] name in
            self?.nameIsValid = !name.isEmpty
        }
    }
    
    deinit {
//        print("\(#function) deinit")
    }
    
    var account: Account {
        let accountId = UUID().uuidString
        let accountType: AccountType
        
        if !isUsingStrongSeed {
            switch type {
            case .mnemonic(let words, _):
                let firstTwelveWords = Array(words.prefix(12))
                accountType = .mnemonic(words: firstTwelveWords, salt: "salty_password")
            }
        } else {
            accountType = type
        }
        
        return Account(id: accountId, name: accountName, bip: mnemonicDereviation, type: accountType)
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
    
    func copyToClipboard() {
        let seedString: String
        
        if isUsingStrongSeed {
            seedString = test.seed.reduce(String(), { $0 + " " + $1 })
        } else {
            seedString = test.seed.prefix(12).reduce(String(), { $0 + " " + $1 })
        }
        
        #if os(iOS)
        UIPasteboard.general.string = seedString.dropFirst()
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(String(seedString.dropFirst()), forType: NSPasteboard.PasteboardType.string)
        #endif
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
