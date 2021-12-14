//
//  AccountsView.swift
//  Portal
//
//  Created by Farid on 25.04.2021.
//

import SwiftUI

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
                    LazyVStack_(spacing: 0) {
                        ForEach(viewModel.accounts, id: \.id) { account in
                            AccountItemView(
                                name: account.name,
                                selected: account == viewModel.activeAcount,
                                onDelete: {
                                    onDelete(account: account)
                                }
                            )
                            .id(account.id)
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    if account != viewModel.activeAcount {
                                        viewModel.switchAccount(account: account)
                                    } else {
                                        viewModel.state.modalView = .switchAccount
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
                
                PButton(label: "Create new account", width: 184, height: 32, fontSize: 12, enabled: true) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.state.rootView = .createAccount
                        viewModel.state.modalView = .none
                    }
                }
                .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                                
                PButton(label: "Restore account", width: 184, height: 32, fontSize: 12, enabled: true) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.state.rootView = .restoreAccount
                        viewModel.state.modalView = .none
                    }
                }
                .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .alert(isPresented: $viewModel.showDeletionAlert) {
                Alert(title: Text("This cannot be undone"), message: Text("Want to delete the account?"), primaryButton: .destructive(Text("Delete")) {
                    if let account = viewModel.accountToDelete {
                        viewModel.state.loading = true
                        viewModel.accountToDelete = nil
                        viewModel.state.modalView = .none
                        DispatchQueue.global(qos: .userInitiated).async {
                            viewModel.delete(account: account)
                        }
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
