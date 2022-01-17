//
//  AccountSettingsViewModelTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/12/22.
//

import XCTest
import Combine
@testable import Portal

struct MockedAccountManager: IAccountManager {
    
    private let mockedAccount = Account(
        id: UUID().uuidString,
        name: "Mocked",
        bip: .bip44,
        type: .mnemonic(words: [], salt: String())
    )
    
    private let accountToSave = Account(
        id: "accountToSave",
        name: "Account to save",
        bip: .bip44,
        type: .mnemonic(words: [], salt: String())
    )
    
    private let accountToDelete = Account(
        id: "accountToDelete",
        name: "Account to delete",
        bip: .bip49,
        type: .mnemonic(words: [], salt: String())
    )
    
    var onActiveAccountUpdate: PassthroughSubject<Account?, Never> = PassthroughSubject<Account?, Never>()
    
    var accounts: [Account] {
        [mockedAccount]
    }
    
    var activeAccount: Account? {
        mockedAccount
    }
    
    func account(id: String) -> Account? {
        mockedAccount
    }
    
    func updateWalletCurrency(code: String) {
        
    }
    
    func setActiveAccount(id: String) {
        onActiveAccountUpdate.send(accountToSave)
    }
    
    func save(account: Account) {
        onActiveAccountUpdate.send(accountToDelete)
    }
    
    func update(account: Account) {
        
    }
    
    func delete(account: Account) {
        onActiveAccountUpdate.send(accountToDelete)
    }
    
    func delete(accountId: String) {
        
    }
    
    func clear() {
        
    }
}

import BitcoinKit
import EthereumKit

class AccountSettingsViewModelTests: XCTestCase {
    
    private let adapterManager: IAdapterManager = MockedAdapterManager()
    private let accountManager: IAccountManager = MockedAccountManager()
    
    private var sut: AccountSettingsViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = AccountSettingsViewModel.init(accountManager: accountManager, adapterManager: adapterManager)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }


    func testDefaultValues() throws {
        XCTAssertNotNil(sut.account)
        XCTAssertEqual(sut.btcNetwork, BitcoinKit.Kit.NetworkType.testNet)
        XCTAssertEqual(sut.ethNetwork, EthereumKit.NetworkType.ropsten)
        XCTAssertEqual(sut.ethNetworkString, "ropsten")
        XCTAssertEqual(sut.confirmationThreshold, 0)
        XCTAssertEqual(sut.canApplyChanges, false)
        XCTAssertEqual(sut.infuraKeyString, String())
    }
    
    func testEthNetworkStringMainNet() throws {
        sut.ethNetwork = .ethMainNet
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.ethNetworkString, "mainNet")
    }
    
    func testEthNetworkStringKovan() throws {
        sut.ethNetwork = .kovan
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.ethNetworkString, "kovan")
    }
    
    func testEthNetworkStringRopsten() throws {
        sut.ethNetwork = .ropsten
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.ethNetworkString, "ropsten")
    }
    
    func testEthNetworkStringBscMainNet() throws {
        sut.ethNetwork = .bscMainNet
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.ethNetworkString, "bscMainNet")
    }
    
    func testBtcNetworkChangesTriggersCanApplyChanges() throws {
        XCTAssertEqual(sut.canApplyChanges, false)
        
        sut.btcNetwork = .mainNet
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.canApplyChanges, true)
    }
    
    func testEthNetworkChangesTriggersCanApplyChanges() throws {
        XCTAssertEqual(sut.canApplyChanges, false)
        
        sut.ethNetwork = .bscMainNet
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.canApplyChanges, true)
    }
    
    func testConfirmationThresholdChangesTriggersCanApplyChanges() throws {
        XCTAssertEqual(sut.canApplyChanges, false)
        
        sut.confirmationThreshold = 5
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.canApplyChanges, true)
    }
    
    func testInfuraKetStringChangesTriggersCanApplyChanges() throws {
        XCTAssertEqual(sut.canApplyChanges, false)
        
        sut.infuraKeyString = String()
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.canApplyChanges, true)
    }
    
    func testApplySettings() throws {
        XCTAssertNotEqual(sut.account.btcNetworkType, BitcoinKit.Kit.NetworkType.mainNet)
        XCTAssertNotEqual(sut.account.ethNetworkType, EthereumKit.NetworkType.ethMainNet)
        XCTAssertNotEqual(sut.account.confirmationsThreshold, 10)
        
        sut.btcNetwork = .mainNet
        sut.ethNetwork = .ethMainNet
        sut.confirmationThreshold = 10
        
        sut.applySettings()
                
        XCTAssertEqual(sut.account.btcNetworkType, BitcoinKit.Kit.NetworkType.mainNet)
        XCTAssertEqual(sut.account.ethNetworkType, EthereumKit.NetworkType.ethMainNet)
        XCTAssertEqual(sut.account.confirmationsThreshold, 10)
    }
    
    func testConfig() throws {
        sut = AccountSettingsViewModel.config()
        XCTAssertNotNil(sut)
    }
}
