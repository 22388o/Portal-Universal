//
//  RestoreAccountViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/17/22.
//

import XCTest
@testable import Portal

class RestoreAccountViewModelUnitTests: XCTestCase {
    
    private var sut: RestoreAccountViewModel!
    private let mnemonicWords = [
        "kit", "clog", "mesh", "scrap", "blood", "frost", "siege", "blind", "combine", "model", "village", "comics", "rival", "august", "develop", "betray", "boy", "surprise", "unusual", "strike", "sound", "morning", "escape", "alter"
    ]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = RestoreAccountViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testAccount() throws {
        let accountName = "Account name"
        sut.accountName = accountName
                
        XCTAssertEqual(sut.account.id.isEmpty, false)
        XCTAssertEqual(sut.account.name, accountName)
        XCTAssertEqual(sut.account.mnemonicDereviation, MnemonicDerivation.bip49)
        
        sut.btcAddressFormat = BtcAddressFormat.legacy.rawValue
        XCTAssertEqual(sut.account.mnemonicDereviation, MnemonicDerivation.bip44)
        
        sut.btcAddressFormat = BtcAddressFormat.nativeSegwit.rawValue
        XCTAssertEqual(sut.account.mnemonicDereviation, MnemonicDerivation.bip84)
    }
    
    func testSeedData() throws {
        XCTAssertNotNil(sut.seedData, "seed data is nil")
    }
    
    func testErrorMessage() throws {
        XCTAssertEqual(sut.errorMessage, "Account name must be at least 1 symbols long")
        sut.accountName = "Name"
        XCTAssertEqual(sut.errorMessage, "Invalid seed! Please try again.")
        sut.seed = [mnemonicWords[0], mnemonicWords[1], mnemonicWords[2]]
        XCTAssertEqual(sut.errorMessage, "Invalid seed! Please try again.")
        sut.seed = mnemonicWords
        XCTAssertEqual(sut.errorMessage, String())
    }
    
    func testRestoreReady() throws {
        sut.accountName = String()
        XCTAssertEqual(sut.restoreReady, false)
        sut.seed = [mnemonicWords[0], mnemonicWords[1], mnemonicWords[2]]
        XCTAssertEqual(sut.restoreReady, false)
        sut.seed = mnemonicWords
        XCTAssertEqual(sut.restoreReady, false)
        sut.accountName = "name"
        XCTAssertEqual(sut.restoreReady, true)
    }
}
