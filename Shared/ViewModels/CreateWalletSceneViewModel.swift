//
//  CreateWalletSceneViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Combine

final class CreateWalletSceneViewModel: ObservableObject {
    @Published var walletCreationStep: WalletCreationSteps = .createWalletName
    @Published var walletName = String()
    @Published var btcAddressFormat = BtcAddressFormat.segwit.rawValue
    @Published var test: SeedTestViewModel
    
    @Published private(set) var nameIsValid: Bool = false
    
    private var cancalable: AnyCancellable?
    
    init() {
        self.test = SeedTestViewModel(seed: try! NewWalletModel.generateWords())
        
        cancalable = $walletName.sink { [weak self] name in
            self?.nameIsValid = name.count >= 3
        }
    }
    
    deinit {
        print("\(#function) deinit")
    }
    
    var newWalletViewModel: NewWalletModel {
        .init(
            name: walletName,
            addressType: BtcAddressFormat(rawValue: btcAddressFormat) ?? .segwit,
            seed: test.seed
        )
    }
}
