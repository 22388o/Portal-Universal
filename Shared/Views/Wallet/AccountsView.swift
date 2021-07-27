//
//  AccountsView.swift
//  Portal
//
//  Created by Farid on 25.04.2021.
//

import SwiftUI

class AccountsViewModel: ObservableObject {
    private let manager: IAccountManager
    
    @Published var state: PortalState
    @Published var showDeletionAlert: Bool = false
    @Published var accountToDelete: Account?
    
    @Published private(set) var accounts: [Account] = []
    @Published private(set) var activeAcount: Account?
    
    init(accountManager: IAccountManager, state: PortalState) {
        self.manager = accountManager
        self.state = state
        
        accounts = manager.accounts
        activeAcount = manager.activeAccount
    }
    
    func switchAccount(account: Account) {
        manager.setActiveAccount(id: account.id)
        activeAcount = manager.activeAccount
    }
    
    func delete(account: Account) {
        manager.delete(account: account)
    }
}

extension AccountsViewModel {
    static func config() -> AccountsViewModel {
        let accountManager = Portal.shared.accountManager
        let state = Portal.shared.state
        return AccountsViewModel(accountManager: accountManager, state: state)
    }
}

struct AccountsView: View {
    @ObservedObject private var viewModel: AccountsViewModel
    
    init() {
        viewModel = AccountsViewModel.config()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.94))
                .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 2)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Accounts")
                        .font(.mainFont(size: 12, bold: true))
                        .foregroundColor(Color.walletsLabel)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 9)
                    Spacer()
                }
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.accounts, id: \.id) { account in
                            AccountItemView(
                                name: account.name,
                                selected: account == viewModel.activeAcount,
                                onDelete: {
                                    onDelete(account: account)
                                }
                            )
                            .onTapGesture {
                                withAnimation {
                                    if account != viewModel.activeAcount {
                                        viewModel.switchAccount(account: account)
                                    }
                                    viewModel.state.switchWallet.toggle()
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
                
                PButton(label: "Create new account", width: 184, height: 32, fontSize: 12, enabled: true) {
                    withAnimation {
                        viewModel.state.current = .createAccount
                        viewModel.state.switchWallet.toggle()
                    }
                }
                                
                PButton(label: "Restore account", width: 184, height: 32, fontSize: 12, enabled: true) {
                    withAnimation {
                        viewModel.state.current = .restoreAccount
                        viewModel.state.switchWallet.toggle()
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .alert(isPresented: $viewModel.showDeletionAlert) {
                Alert(title: Text("This cannot be undone"), message: Text("Want to delete the account?"), primaryButton: .destructive(Text("Delete")) {
                    if let account = viewModel.accountToDelete {
                        withAnimation {
                            viewModel.delete(account: account)
                            viewModel.state.switchWallet.toggle()
                        }
                        viewModel.accountToDelete = nil
                    }
                },secondaryButton: .cancel())
            }
        }
        .frame(width: 216, height: 333)
        .transition(.move(edge: .leading))
    }
    
    private func onDelete(account: Account) {
        viewModel.accountToDelete = account
        viewModel.showDeletionAlert.toggle()
    }
}

struct SwitchWalletsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView()
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
