//
//  HeaderViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/14/22.
//

import XCTest
@testable import Portal

class HeaderViewModelUnitTests: XCTestCase {

    private var sut: HeaderViewModel!
    private let accountManager = MockedAccountManager()
    private let reachabilityService = MockedReachabilityService()
    private let notificationService = MockedNotificationService()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = HeaderViewModel.init(
            accountManager: accountManager,
            notificationService: notificationService,
            reachabilityService: reachabilityService,
            currencies: [Currency.btc, Currency.eth]
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testConfig() throws {
        sut = HeaderViewModel.config()
        XCTAssertNotNil(sut)
    }
    
    func testDefaultValues() throws {
        XCTAssertEqual(sut.accountName, "Mocked")
        XCTAssertNotNil(sut.state)
        XCTAssertEqual(sut.hasBadge, false)
        XCTAssertEqual(sut.newAlerts, 0)
        XCTAssertEqual(sut.isOffline, false)
    }
    
    func testCurrenciesItSet() throws {
        XCTAssertTrue(!sut.currencies.isEmpty)
    }
    
    func testOnActiveAccountUpdateSubscription() throws {
        XCTAssertEqual(sut.accountName, "Mocked")

        let account = Account(id: UUID().uuidString, name: "Newly Mocked", bip: .bip44, type: .mnemonic(words: [], salt: String()))
        
        accountManager.onActiveAccountUpdate.send(account)
        
        let promise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.accountName, account.name)
        
        accountManager.onActiveAccountUpdate.send(nil)
        
        let promise1 = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise1.fulfill()
        }
        
        wait(for: [promise1], timeout: 0.2)
        XCTAssertEqual(sut.accountName, "-")
    }
    
    func testHasBadge() throws {
        XCTAssertEqual(sut.hasBadge, false)
        
        let notification = PNotification(message: "Test")
        notificationService.notify(notification)
        
        let promise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.hasBadge, true)
    }
    
    func testnewAlertsIncremented() throws {
        XCTAssertEqual(sut.newAlerts, 0)
        
        let notification = PNotification(message: "Test")
        notificationService.notify(notification)
        
        let promise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.newAlerts, 1)
    }
    
    func testMarkAllNotificationsViewed() throws {
        let notification = PNotification(message: "Test")
        notificationService.notify(notification)
                
        let promise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        
        XCTAssertEqual(sut.newAlerts, 1)
        XCTAssertEqual(sut.hasBadge, true)
        
        sut.markAllNotificationsViewed()

        let promise1 = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise1.fulfill()
        }
        
        wait(for: [promise1], timeout: 0.2)
        
        XCTAssertEqual(sut.newAlerts, 0)
        XCTAssertEqual(sut.hasBadge, false)
    }
}
