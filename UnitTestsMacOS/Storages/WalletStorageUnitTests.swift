//
//  WalletStorageUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/21/22.
//

import XCTest
@testable import Portal

import Combine

class MockedCoinMannager: ICoinManager {
    var onCoinsUpdate = PassthroughSubject<[Coin], Never>()
    var coins: [Coin] = []
    
    func addCoins() {
        coins = [.bitcoin(), .ethereum()]
    }
}

class WalletStorageUnitTests: XCTestCase {
    
    private var sut: WalletStorage!
    private var subscriptions = Set<AnyCancellable>()
    private let accountMannager: IAccountManager = MockedAccountManager()
    private var coinMannager = MockedCoinMannager()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = WalletStorage(coinManager: coinMannager, accountManager: accountMannager)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testOnActiveAccountUpdateUpdatesWallets() throws {
        XCTAssertEqual(sut.wallets.count, 0)
        
        coinMannager.addCoins()
        
        let promise = expectation(description: "wallets updated")
        
        sut.onWalletsUpdate.sink(receiveValue: { wallets in
            XCTAssertNotNil(wallets, "wallets are nil")
            promise.fulfill()
        })
        .store(in: &subscriptions)
        
        accountMannager.onActiveAccountUpdate.send(nil)
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(sut.wallets.count, 2)
    }
    
    func testOnCoinsUpdateUpdatesWallets() throws {
        XCTAssertEqual(sut.wallets.count, 0)

        coinMannager.addCoins()
        
        let promise = expectation(description: "wallets updated")
        
        sut.onWalletsUpdate.sink(receiveValue: { wallets in
            XCTAssertNotNil(wallets, "wallets are nil")
            promise.fulfill()
        })
        .store(in: &subscriptions)
        
        coinMannager.onCoinsUpdate.send([])
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(sut.wallets.count, 2)
    }
    
    func testClearWallets() throws {
        coinMannager.addCoins()
        
        sut = WalletStorage(coinManager: coinMannager, accountManager: accountMannager)
        
        XCTAssertEqual(sut.wallets.count, 2)
        
        sut.clearWallets()
        
        XCTAssertEqual(sut.wallets.count, 0)
    }
}
