//
//  WalletViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/17/22.
//

import XCTest
@testable import Portal

class WalletViewModelUnitTests: XCTestCase {
    
    private var sut: WalletViewModel!
    private let walletManager: IWalletManager = MockedWalletManager()
    private let adapterManager: IAdapterManager = MockedAdapterManager()
    private let marketDataProvider: IMarketDataProvider = MockedMarketDataProvider()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = WalletViewModel(
            walletManager: walletManager,
            adapterManager: adapterManager,
            marketDataProvider: marketDataProvider
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testConfig() throws {
        let configuredViewModel = WalletViewModel.config()
        XCTAssertNotNil(configuredViewModel, "config returns nil")
    }
    
    func testAdapterReadySubscription() throws {
        XCTAssertEqual(sut.items.isEmpty, true)
        
        adapterManager.adapterdReady.send(true)
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        
        XCTAssertEqual(sut.items.isEmpty, false)
        XCTAssertEqual(sut.items.count, 1)
    }
}
