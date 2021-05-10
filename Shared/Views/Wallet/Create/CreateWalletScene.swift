//
//  CreateWalletScene.swift
//  Portal
//
//  Created by Farid on 04.04.2021.
//

import SwiftUI

struct CreateWalletScene: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(walletService: WalletsService) {
        self.viewModel = ViewModel(walletService: walletService)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            Color.portalWalletBackground
            
            HStack(spacing: 12) {
                Group {
                    Text("Welcome to Portal")
                        .font(.mainFont(size: 14, bold: true))
                    Group {
                        Text("|")
                        Text("Set up a wallet")
                    }
                    .font(.mainFont(size: 14))
                }
                .foregroundColor(.white)
            }
            .padding(.top, 35)
            
            HStack {
                PButton(label: "Go back", width: 80, height: 30, fontSize: 12, enabled: true) {
                    withAnimation {
                        viewModel.goBack()
                    }
                }
                Spacer()
            }
            .padding(.top, 30)
            .padding(.leading, 30)
            
            ZStack {
                Color.black.opacity(0.58)
                                
                HStack(spacing: 0) {
                    if viewModel.walletCreationStep == .createWalletName {
                        TopCoinView()
                            .frame(width: 312)
                            .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.white)
                            .cornerRadius(5)
                            .padding(viewModel.walletCreationStep == .createWalletName ? [.vertical, .trailing] : .all, 8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Group {
                            switch viewModel.walletCreationStep {
                            case .createWalletName:
                                CreateWalletNameView(viewModel: viewModel)
                            case .seed:
                                StoreSeedView(viewModel: viewModel)
                            case .test:
                                SeedTestView(viewModel: viewModel)
                            case .confirmation:
                                EmptyView()
                            }
                        }
                        .zIndex(1)
                        .transition(
                            AnyTransition.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            )
                            .combined(with: .opacity)
                        )
                        .padding(.horizontal, 40)
                    }
                    .zIndex(1)
                }
            }
            .cornerRadius(8)
            .padding(EdgeInsets(top: 88, leading: 24, bottom: 24, trailing: 24))
        }
    }
}

import Combine

extension CreateWalletScene {
    enum WalletCreationSteps {
        case createWalletName, seed, test, confirmation
    }
    
    final class ViewModel: ObservableObject {
        @ObservedObject private var walletService: WalletsService
        
        @Published var walletCreationStep: WalletCreationSteps = .createWalletName
        @Published var walletName = String()
        @Published var btcAddresSelectcedFormat = BtcAddressFormat.segwit.rawValue
        @Published var test: SeedTestViewModel
        
        @Published private(set) var nameIsValid: Bool = false
        
        private var cancalable: AnyCancellable?
        
        init(walletService: WalletsService) {
            self.walletService = walletService
            self.test = SeedTestViewModel()
            
            cancalable = $walletName.sink { [weak self] name in
                self?.nameIsValid = name.count >= 3
            }
        }
        
        deinit {
            print("\(#function) deinit")
        }
        
        func creteNewWallet() {
            let newWalletModel: NewWalletModel = .init(
                name: walletName,
                addressType: BtcAddressFormat(rawValue: btcAddresSelectcedFormat) ?? .segwit,
                seed: test.seed
            )
            walletService.createWallet(model: newWalletModel)
        }
        
        func goBack() {
            walletService.state = .currentWallet
        }
    }
    
    final class SeedTestViewModel: ObservableObject {
        @Published var testString1 = String()
        @Published var testString2 = String()
        @Published var testString3 = String()
        @Published var testString4 = String()
        
        private(set) var formIsValid = false
        private(set) var testIndices = [Int]()
        
        private var testSolved = [String]()
        
        let seed: [String]
    
        private var cancalable: AnyCancellable?

        init(seed: [String] = NewWalletModel.randomSeed()) {
            self.seed = seed
            setup()
        }
        
        deinit {
            print("\(#function) deinit")
        }
        
        func setup() {
            while testIndices.count <= 3 {
                let 🎲 = Int.random(in: 1..<seed.count)
                if !testIndices.contains(🎲) {
                    testIndices.append(🎲)
                }
            }
                                           
            for index in testIndices {
                testSolved.append(seed[index - 1])
            }
                        
            bindInputs()
            
            print("Test solved: \(testSolved)")
        }
        
        private func bindInputs() {
            cancalable = $testString1.combineLatest($testString2, $testString3, $testString4)
                .sink(receiveValue: { [weak self] output in
                    self?.formIsValid = self?.testSolved == [output.0, output.1, output.2, output.3]
                })
        }
    }
}

struct CreateWalletScene_Previews: PreviewProvider {
    static var previews: some View {
        CreateWalletScene(walletService: WalletsService())
            .iPadLandscapePreviews()
    }
}
