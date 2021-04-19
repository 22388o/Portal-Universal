//
//  SeedTestView.swift
//  Portal
//
//  Created by Farid on 06.04.2021.
//

import SwiftUI

struct SeedTestView: View {
    @ObservedObject private var viewModel: CreateWalletScene.ViewModel
    @ObservedObject private var keyboard = KeyboardResponder()

    init(viewModel: CreateWalletScene.ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Image("lockedSafeIcon")
            
            Text("Confirm the seed")
                .font(.mainFont(size: 24))
                .padding(.top, 30)
                .padding(.bottom, 13)
            
            Text("Let’s see if you wrote the seed correctly:\nenter the following words from your seed.")
                .font(.mainFont(size: 14))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 0) {
                HStack(spacing: 26) {
                    VStack(alignment: .leading, spacing: 9) {
                        Text("\(viewModel.test.testIndices[0])) word")
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString1, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                        Text("\(viewModel.test.testIndices[1])) word")
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString2, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                    }
                    VStack(alignment: .leading, spacing: 9) {
                        Text("\(viewModel.test.testIndices[2])) word")
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString3, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                        Text("\(viewModel.test.testIndices[3])) word")
                            .font(.mainFont(size: 14))
                        PTextField(text: $viewModel.test.testString4, placeholder: "Enter word", upperCase: false, width: 192, height: 48)
                    }
                }
                .padding(.top, 25)
                .padding(.bottom, 30)
                
                Text("Your wallet will be ready when words are correct.")
                    .font(.mainFont(size: 14))
                
                Spacer().frame(height: 21)
                
                PButton(label: "Create my wallet", width: 203, height: 48, fontSize: 15, enabled: viewModel.test.formIsValid) {
                    withAnimation {
                        viewModel.creteNewWallet()
                    }
                }
            }
            .padding(.bottom, keyboard.currentHeight)
        }
    }
}

import Combine

extension SeedTestView {
    final class ViewModel: ObservableObject {
        @Published var testString1 = String()
        @Published var testString2 = String()
        @Published var testString3 = String()
        @Published var testString4 = String()
        
        private(set) var formIsValid = false
        
        private var testIndices = [Int]()
        private var testSolved = [String]()
        private var newWalletModel: NewWalletModel
    
        private var cancalable: AnyCancellable?

        init(newWalletModel: NewWalletModel) {
            self.newWalletModel = newWalletModel
        }
        
        func setup() {
            while testIndices.count <= 3 {
                let 🎲 = Int.random(in: 1..<newWalletModel.seed.count)
                if !testIndices.contains(🎲) {
                    testIndices.append(🎲)
                }
            }
                                           
            for index in testIndices {
                testSolved.append(newWalletModel.seed[index - 1])
            }
                        
            bindInputs()
        }
        
        private func bindInputs() {
            cancalable = $testString1.combineLatest($testString2, $testString3, $testString4)
                .sink(receiveValue: { [weak self] output in
                    self?.formIsValid = self?.testSolved == [output.0, output.1, output.2, output.3]
                })
        }
    }
}

struct SeedTestView_Previews: PreviewProvider {
    static var previews: some View {
        SeedTestView(viewModel: CreateWalletScene.ViewModel(walletService: WalletsService()))
            .frame(width: 750, height: 656)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}

final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}
