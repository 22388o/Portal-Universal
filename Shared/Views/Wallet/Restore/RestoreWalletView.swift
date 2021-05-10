//
//  RestoreWalletView.swift
//  Portal
//
//  Created by Farid on 09.05.2021.
//

import SwiftUI

struct RestoreWalletView: View {
    @ObservedObject var viewModel: ViewModel
    
    init(walletService: WalletsService) {
        viewModel = .init(service: walletService)
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
                        Text("Restore wallet")
                    }
                    .font(.mainFont(size: 14))
                }
                .foregroundColor(.white)
            }
            .padding(.top, 35)
            
            if viewModel.walletService.currentWallet != nil {
                HStack {
                    PButton(label: "Go back", width: 80, height: 30, fontSize: 12, enabled: true) {
                        withAnimation {
                            viewModel.walletService.state = .currentWallet
                        }
                    }
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.leading, 30)
            }
            
            ZStack {
                Color.black.opacity(0.58)
                
                Color.white.cornerRadius(5).padding(8)
                                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 14) {
                        Image("lockedSafeIcon")
                            .offset(y: -2)
                        Text("Restore Wallet")
                            .font(.mainFont(size: 23))
                    }
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Acount name")
                            .font(.mainFont(size: 18))
                        PTextField(text: $viewModel.accountName, placeholder: "Enter account name", upperCase: true, width: 360, height: 40)
                    }
                    .padding(.top, 20)
                    
                    Text("Seed")
                        .font(.mainFont(size: 18))
                        .padding(.top, 13)
                        .padding(.bottom, 10)
                    
                    VStack {
                        ForEach(0...5, id: \.self) { row in
                            HStack {
                                ForEach(1...4, id: \.self)  { index in
                                    RestoreSeedField(text: $viewModel.seed[(row * 4 + index) - 1], index: row * 4 + index)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        PButton(label: "Restore", width: 203, height: 48, fontSize: 15, enabled: viewModel.restoreReady) {
                            withAnimation {
                                viewModel.walletService.createWallet(model: .init(name: viewModel.accountName, addressType: .nativeSegwit, seed: viewModel.seed))
                            }
                        }
                        
                        if !viewModel.restoreReady {
                            HStack {
                                Image(systemName: "exclamationmark.circle").font(.system(size: 16, weight: .regular))
                                Text(viewModel.errorMessage)
                                    .font(.mainFont(size: 14))
                            }
                            .foregroundColor(Color(red: 250/255, green: 147/255, blue: 36/255))
                            .padding()
                        } else {
                            EmptyView()
                        }
                        
                        Spacer()
                        
                        PButton(label: "Create new wallet", width: 140, height: 30, fontSize: 12, enabled: true) {
                            withAnimation {
                                viewModel.walletService.state = .createWallet
                            }
                        }
                    }
                    .frame(width: 725)
                    .padding(.top, 20)
                }
            }
            .cornerRadius(8)
            .padding(EdgeInsets(top: 88, leading: 24, bottom: 24, trailing: 24))
        }
    }
}

import Combine

extension RestoreWalletView {
    final class ViewModel: ObservableObject {
        @ObservedObject var walletService: WalletsService
        private let seeedLength = 24
        private var anyCancellable = Set<AnyCancellable>()

        @Published var accountName = String()
        @Published var seed = [String]()
        @Published private(set) var restoreReady: Bool = false
        
        var errorMessage: String {
            if accountName.isEmpty {
                return "Enter account name"
            } else if accountName.count < 3 {
                return "Account name must be at least 3 symbols long"
            } else {
                let filteredSeedArray = seed.filter { $0.count >= 3 }
                return filteredSeedArray.count != seeedLength ? "Invalid seed! Please try again." : String()
            }
        }
        
        init(service: WalletsService) {
            walletService = service
            
            for _ in 1...seeedLength {
                seed.append(String())
            }
            
            $accountName
                .sink(receiveValue: { [unowned self] name in
                    let filteredSeedArray = seed.filter { $0.count >= 3 }
                    self.restoreReady = name.count >= 3 && filteredSeedArray.count == seeedLength
                })
                .store(in: &anyCancellable)
            
            $seed
                .sink { [unowned self] seedArray in
                    let filteredSeedArray = seedArray.filter { $0.count >= 3 }
                    self.restoreReady = !self.accountName.isEmpty && filteredSeedArray.count == seeedLength
                }
                .store(in: &anyCancellable)
                
        }
    }
}

struct RestoreWalletView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreWalletView(walletService: WalletsService())
            .iPadLandscapePreviews()
    }
}
