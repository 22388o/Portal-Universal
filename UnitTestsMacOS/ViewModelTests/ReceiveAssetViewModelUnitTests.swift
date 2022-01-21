//
//  ReceiveAssetViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/17/22.
//

import XCTest
@testable import Portal

class ReceiveAssetViewModelUnitTests: XCTestCase {
    
    private var sut: ReceiveAssetViewModel!
    private let testNetEthAddress = "0xf70E711BFAc76813685098D32c287195C3FA2F38"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = ReceiveAssetViewModel(address: testNetEthAddress)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testConfig() throws {
        sut = ReceiveAssetViewModel.config(coin: .bitcoin())
        XCTAssertNotNil(sut, "config return nil")
    }
    
    func testReceiverAddress() throws {
        XCTAssertEqual(sut.receiveAddress, testNetEthAddress)
    }
    
    func testUpdate() throws {
        XCTAssertNil(sut.qrCode)
        sut.update()
        XCTAssertNotNil(sut.qrCode)

    }
    
    func testCopyToClipboard() throws {
        sut.copyToClipboard()
        
        #if os(iOS)
        XCTAssertEqual(UIPasteboard.general.string, testNetEthAddress)
        #else
        let testString = NSPasteboard.general.string(forType: .string)
        XCTAssertNotNil(testString, "pastboard test is empty")
        XCTAssertEqual(testString, testNetEthAddress)
        #endif
    }
}
