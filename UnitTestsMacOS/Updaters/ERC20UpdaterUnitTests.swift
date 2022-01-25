//
//  ERC20UpdaterUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/25/22.
//

import XCTest
@testable import Portal
import Combine

class ERC20UpdaterUnitTests: XCTestCase {
    
    private var sut: ERC20Updater!
    private var subsriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        subsriptions.removeAll()
    }
    
    func testOnTokensUpdate() throws {
        sut = ERC20Updater()
        
        let promisse = expectation(description: "Tokens fetched")
        
        sut.onTokensUpdate.sink { tokens in
            XCTAssertNotNil(tokens, "Tokens are nil")
            XCTAssertEqual(tokens.filter{ $0.iconURL.isEmpty }.count, 0)
            promisse.fulfill()
        }
        .store(in: &subsriptions)
        
        wait(for: [promisse], timeout: 5)
    }
    
    func testOnTokensUpdateLoadsLocallyStoredTokensIfFetchingFails() throws {
        sut = ERC20Updater(jsonDecoder: JSONDecoder(), url: URL(string: "https://www.google.com"))
        
        let promisse = expectation(description: "Locally stored tokens fetched")
        
        sut.onTokensUpdate.sink { tokens in
            XCTAssertNotNil(tokens, "Tokens are nil")
            XCTAssertEqual(tokens.filter{ $0.iconURL.isEmpty }.count, 0)
            XCTAssertEqual(tokens.count, 709)
            promisse.fulfill()
        }
        .store(in: &subsriptions)
        
        wait(for: [promisse], timeout: 5)
    }
}
