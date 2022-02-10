//
//  ExchangeDataUpdaterUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/25/22.
//

import XCTest
@testable import Portal
import Combine

class ExchangeDataUpdaterUnitTests: XCTestCase {
    
    private var sut: ExchangeDataUpdater!
    private var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = ExchangeDataUpdater()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        subscriptions.removeAll()
    }
    
    func testOnExchangesUpdate() throws {
        let promise = expectation(description: "Exchanges are updated")
        
        sut.onExchangesUpdate.sink { exchanges in
            XCTAssertNotNil(exchanges)
            XCTAssertEqual(exchanges.count, 3)
            promise.fulfill()
        }
        .store(in: &subscriptions)
        
        wait(for: [promise], timeout: 5)
    }
    
    func testOnTraidingPairsUpdate() throws {
        let promise = expectation(description: "Trading pairs are updated")
        
        sut.onTraidingPairsUpdate.sink { tradingPairs in
            XCTAssertNotNil(tradingPairs)
            promise.fulfill()
        }
        .store(in: &subscriptions)
        
        wait(for: [promise], timeout: 5)
    }
}
