//
//  AccountViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/17/22.
//

import XCTest
@testable import Portal
import Combine

class AccountViewModelUnitTests: XCTestCase {
    
    private var sut: AccountsViewModel!
    private let accountManager: IAccountManager = MockedAccountManager()
    private let state = PortalState()
    private var subscriptions = Set<AnyCancellable>()
    private let accountToDelete = Account(
        id: "accountToDelete",
        name: "Account to delete",
        bip: .bip49,
        type: .mnemonic(words: [], salt: String())
    )

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = AccountsViewModel(accountManager: accountManager, state: state)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testConfig() throws {
        sut = AccountsViewModel.config()
        XCTAssertNotNil(sut, "config returns nil")
    }
    
    func testDefaultValues() throws {
        XCTAssertEqual(sut.accounts, accountManager.accounts)
        XCTAssertEqual(sut.showDeletionAlert, false)
        XCTAssertEqual(sut.activeAcount, accountManager.activeAccount)
        XCTAssertNil(sut.accountToDelete, "account to delet is not nil")
    }
    
    func testSwitchAccount() throws {
        state.modalView = .switchAccount
        state.loading = false
        state.wallet.coin = .ethereum()
        
        sut.switchAccount(account: accountToDelete)
        
        XCTAssertEqual(state.loading, true)
        XCTAssertEqual(state.modalView, .none)
        XCTAssertEqual(state.wallet.coin, .ethereum())
    }
    
    func testDeleteAccount() throws {
        accountManager
            .onActiveAccountUpdate
            .sink { account in
                XCTAssertEqual(account, self.accountToDelete)
            }
            .store(in: &subscriptions)
        
        sut.delete(account: accountToDelete)
    }
}
