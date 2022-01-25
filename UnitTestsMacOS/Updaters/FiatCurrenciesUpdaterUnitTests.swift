//
//  FiatCurrenciesUpdaterUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/25/22.
//

import XCTest
@testable import Portal
import Combine

class FiatCurrenciesUpdaterUnitTests: XCTestCase {
    
    private var sut: FiatCurrenciesUpdater!
    private let appConfigProvider = AppConfigProvider()
    private var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        sut = FiatCurrenciesUpdater(
            interval: TimeInterval(appConfigProvider.fiatCurrenciesUpdateInterval),
            fixerApiKey: appConfigProvider.fixerApiKey
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        subscriptions.removeAll()
    }
    
    func testOnFiatCurrenciesUpdate() throws {
        let promisse = expectation(description: "Fiat currencies are fetched")
        
        sut.onFiatCurrenciesUpdate.sink { currencies in
            XCTAssertNotNil(currencies, "Currencies are not fetched")
            promisse.fulfill()
        }
        .store(in: &subscriptions)
        
        wait(for: [promisse], timeout: 3)
    }
}
