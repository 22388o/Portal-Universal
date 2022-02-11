//
//  AssetAllocationViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/17/22.
//

import XCTest
@testable import Portal

class AssetAllocationViewModelUnitTests: XCTestCase {
    
    private var sut: AssetAllocationViewModel!
    private let balanceAdapter: IBalanceAdapter = MockedBalanceAdapter()
    private let transactionAdapter: ITransactionsAdapter = MockedTransactionAdapter()
    private let marketDataProvider: IMarketDataProvider = MockedMarketDataProvider()
    
    private var items: [PortfolioItem] = []

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        items = [
            PortfolioItem(coin: .bitcoin(), balanceAdapter: balanceAdapter, transactionAdapter: transactionAdapter, marketDataProvider: marketDataProvider),
            PortfolioItem(coin: .ethereum(), balanceAdapter: balanceAdapter, transactionAdapter: transactionAdapter, marketDataProvider: marketDataProvider)
        ]
        sut = AssetAllocationViewModel(assets: items)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testDefaultValues() throws {
        XCTAssertEqual(sut.assets, items)
        XCTAssertEqual(sut.isLineChart, false)
    }
}
