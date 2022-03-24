//
//  CoinStorageUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/23/22.
//

import XCTest
@testable import Portal

class CoinStorageUnitTests: XCTestCase {
    
    private var sut: CoinStorage!
    private let erc20Updater = MockedERC20Updater()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = CoinStorage(updater: erc20Updater, marketDataProvider: MockedMarketDataProvider())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    
    func testOnTokensUpdateSubscription() throws {
        XCTAssertEqual(sut.coins.value.isEmpty, true)
        
        let btcToken = Erc20TokenCodable.mockedBTCToken
        let ethToken = Erc20TokenCodable.mockedETHToken
        
        erc20Updater.onTokensUpdate.send([ethToken])
        
        XCTAssertEqual(sut.coins.value.isEmpty, false)
        
        let eth = Coin(
            type: .erc20(address: ethToken.contractAddress),
            code: ethToken.symbol,
            name: ethToken.name,
            decimal: ethToken.decimal,
            iconUrl: ethToken.iconURL
        )
        
        XCTAssertEqual(sut.coins.value[0], eth)
        
        let btc = Coin(
            type: .erc20(address: btcToken.contractAddress),
            code: btcToken.symbol,
            name: btcToken.name,
            decimal: btcToken.decimal,
            iconUrl: btcToken.iconURL
        )
        
        erc20Updater.onTokensUpdate.send([btcToken, ethToken])
        
        XCTAssertEqual(sut.coins.value[0], btc)
        XCTAssertEqual(sut.coins.value[1], eth)
        
        erc20Updater.onTokensUpdate.send([])
    }
    
}
