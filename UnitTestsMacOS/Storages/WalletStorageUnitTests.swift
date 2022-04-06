//
//  WalletStorageUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/21/22.
//

import XCTest
@testable import Portal

import Combine

class MockedCoinManager: ICoinManager {
    var walletCoins = [Coin]()
    var avaliableCoins = [Coin]()
    var onCoinsUpdate = PassthroughSubject<[Coin], Never>()
    
    func addCoins() {
        walletCoins = [.bitcoin(), .ethereum()]
    }
}

class WalletStorageUnitTests: XCTestCase {
    
    private var sut: WalletStorage!
    private var subscriptions = Set<AnyCancellable>()
    private let accountManager: IAccountManager = MockedAccountManager()
    private var coinManager = MockedCoinManager()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = WalletStorage(coinManager: coinManager, accountManager: accountManager)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testOnActiveAccountUpdateUpdatesWallets() throws {
        XCTAssertEqual(sut.wallets.count, 0)
        
        coinManager.addCoins()
        
        let promise = expectation(description: "wallets updated")
        
        sut.onWalletsUpdate.sink(receiveValue: { wallets in
            XCTAssertNotNil(wallets, "wallets are nil")
            promise.fulfill()
        })
        .store(in: &subscriptions)
        
        accountManager.onActiveAccountUpdate.send(nil)
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(sut.wallets.count, 2)
    }
    
    func testOnCoinsUpdateUpdatesWallets() throws {
        XCTAssertEqual(sut.wallets.count, 0)

        coinManager.addCoins()
        
        let promise = expectation(description: "wallets updated")
        
        sut.onWalletsUpdate.sink(receiveValue: { wallets in
            XCTAssertNotNil(wallets, "wallets are nil")
            promise.fulfill()
        })
        .store(in: &subscriptions)
        
        coinManager.onCoinsUpdate.send([])
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(sut.wallets.count, 2)
    }
    
    func testClearWallets() throws {
        coinManager.addCoins()
        
        sut = WalletStorage(coinManager: coinManager, accountManager: accountManager)
        
        XCTAssertEqual(sut.wallets.count, 2)
        
        sut.clearWallets()
        
        XCTAssertEqual(sut.wallets.count, 0)
    }
}
