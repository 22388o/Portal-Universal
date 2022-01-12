//
//  AssetViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/10/22.
//

import XCTest
import SwiftUI
import Combine
@testable import Portal

class AssetViewModelUnitTests: XCTestCase {
    
    @ObservedObject private var state = PortalState()
    
    private let walletManager: IWalletManager = MockedWalletManager()
    private let adapterManager: IAdapterManager = MockedAdapterManager()
    private let marketDataProvider: IMarketDataProvider = MockedMarketDataProvider()
    
    private var sut: AssetViewModel!
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = AssetViewModel.init(
            state: state,
            walletManager: walletManager,
            adapterManager: adapterManager,
            marketDataProvider: marketDataProvider
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        subscriptions = []
    }
    
    func testDefaultValues() throws {
        let currency = sut.currency
        XCTAssertEqual(currency, .fiat(USD))
        
        let timeframe = sut.timeframe
        XCTAssertEqual(timeframe, .day)
        
        let route = sut.route
        XCTAssertEqual(route, .value)
        
        let balanceString = sut.balance
        XCTAssertEqual(balanceString, String())
        
        let totalValueString = sut.totalValue
        XCTAssertEqual(totalValueString, String())
        
        let changeString = sut.change
        XCTAssertEqual(changeString, String())
        
        let chartDataEntries = sut.chartDataEntries
        XCTAssertEqual(chartDataEntries, [])
        
        let canSend = sut.canSend
        XCTAssertEqual(canSend, false)
        
        let txsViewModel = sut.txsViewModel
        XCTAssertNotNil(txsViewModel)
        
        let coin = sut.coin
        XCTAssertNotNil(coin)
    }
    
    func testTotalSupplyStringIsSet() throws {
        let totalSupplyString = sut.totalSupply
        XCTAssertNotEqual(totalSupplyString, "-")
        XCTAssertEqual(totalSupplyString, "18,925,344 BTC")
    }
    
    func testMaxSupplyStringStates() throws {
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        let maxSupplyString = sut.maxSupply
        XCTAssertNotEqual(maxSupplyString, "-")
        XCTAssertEqual(maxSupplyString, "21,000,000 BTC")
        
        state.wallet.coin = Coin.ethereum()
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.maxSupply, "Unlimited")
    }
    
    func testMarketCupStringIsSet() throws {
        let marketCupString = sut.marketCap
        XCTAssertNotEqual(marketCupString, "-")
        XCTAssertEqual(marketCupString, "$779,305,976,685")
    }
    
    func testAthPriceStringIsSet() throws {
        let athPriceString = sut.athPrice
        XCTAssertNotEqual(athPriceString, "-")
        XCTAssertEqual(athPriceString, "$68,692.14")
    }
    
    func testAthDateStringIsSet() throws {
        let athDateString = sut.athDate
        XCTAssertNotEqual(athDateString, "-")
        XCTAssertEqual(athDateString, "2 months ago")
    }
    
    func testVolume24hStringIsSet() throws {
        let volume24hString = sut.volume24h
        XCTAssertNotEqual(volume24hString, "-")
        XCTAssertEqual(volume24hString, "$33,373,797,643.74")
    }
    
    func testPercentFromPriceAthStringIsSet() throws {
        let percentFromPriceAthString = sut.percentFromPriceAth
        XCTAssertNotEqual(percentFromPriceAthString, "-")
        XCTAssertEqual(percentFromPriceAthString, "-40.05%")
    }
    
    func testHighValueStringStates() throws {
        state.wallet.currency = Currency.fiat(USD)

        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.highValue, "$43,127")

        state.wallet.currency = .btc
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.highValue, "1 BTC")
        
        state.wallet.currency = .eth
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.highValue, "14.1577 ETH")
        
        state.wallet.coin = .ethereum()
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.highValue, "1 ETH")
        
        sut.timeframe = .year
        XCTAssertEqual(sut.highValue, "-")
    }
    
    func testLowValueStringStates() throws {
        state.wallet.currency = Currency.fiat(USD)

        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.lowValue, "$42,258")

        state.wallet.currency = .btc
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.lowValue, "1 BTC")
        
        state.wallet.currency = .eth
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.lowValue, "13.8724 ETH")
        
        state.wallet.coin = .ethereum()
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.lowValue, "1 ETH")
        
        sut.timeframe = .year
        XCTAssertEqual(sut.lowValue, "-")
    }
    
    func testChangeLabelColorIsCorrect() throws {
        XCTAssertEqual(sut.changeLabelColor, Color(red: 255/255, green: 156/255, blue: 49/255, opacity: 1))

        sut.timeframe = .year
        
        XCTAssertEqual(sut.changeLabelColor, Color(red: 15/255, green: 235/255, blue: 131/255, opacity: 1))
    }
    
    func testChangeStringStates() throws {
        let promisse = expectation(description: "update coin")

        state.wallet.$coin
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { _ in
                promisse.fulfill()
            }
            .store(in: &subscriptions)
        
        state.wallet.coin = .ethereum()

        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.change, "-$147.74 (-4.85%)")
    }
    
    func testChangeStringForDayTimeframe() throws {
        sut.timeframe = .day
        
        let promisse = expectation(description: "update timeframe: day")
        
        sut.$timeframe
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { _ in
                promisse.fulfill()
            }
            .store(in: &subscriptions)
                    
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.change, "-$1,478.29 (-3.59%)")
    }
    
    func testChangeStringForWeekTimeframe() throws {
        let promisse = expectation(description: "update timeframe: week")
        
        sut.$timeframe
            .dropFirst()
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { _ in
                promisse.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.timeframe = .week
                    
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.change, "-$4,735.46 (-11.5%)")
    }
    
    func testChangeStringForMonthTimeframe() throws {
        let promisse = expectation(description: "update timeframe: month")
        
        sut.$timeframe
            .dropFirst()
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { _ in
                promisse.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.timeframe = .month
                    
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.change, "-$6,040.8 (-14.67%)")
    }
    
    func testChangeStringForYearTimeframe() throws {
        let promisse = expectation(description: "update timeframe: year")
        
        sut.$timeframe
            .dropFirst()
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { _ in
                promisse.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.timeframe = .year
                    
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.change, "+$3,710.13 (9.01%)")
    }
    
    func testTotalValueString() throws {
        XCTAssertEqual(sut.totalValue, String())
        let promisse = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.totalValue, "$41,177.92")
        
        state.wallet.currency = .fiat(FiatCurrency(code: "RUB", name: "Russian Ruble"))
        
        let promisse1 = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse1.fulfill()
        }
                
        wait(for: [promisse1], timeout: 0.2)
        XCTAssertEqual(sut.totalValue, "₽41,177.92")
    }
    
    func testBalanceString() throws {
        XCTAssertEqual(sut.balance, String())
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.balance, "2.25")
    }
    
    func testCanSendSetCorrectly() throws {
        XCTAssertEqual(sut.canSend, false)
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.canSend, true)
    }
}