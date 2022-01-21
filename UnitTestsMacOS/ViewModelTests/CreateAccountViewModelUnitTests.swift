//
//  CreateAccountViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/17/22.
//

import XCTest
@testable import Portal

class CreateAccountViewModelUnitTests: XCTestCase {
    
    private var sut: CreateAccountViewModel!
    private let mnemonicWords = [
        "kit", "clog", "mesh", "scrap", "blood", "frost", "siege", "blind", "combine", "model", "village", "comics", "rival", "august", "develop", "betray", "boy", "surprise", "unusual", "strike", "sound", "morning", "escape", "alter"
    ]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = CreateAccountViewModel(type: .mnemonic(words: mnemonicWords, salt: String()))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testDefaultValues() throws {
        XCTAssertEqual(sut.step, .name)
        XCTAssertEqual(sut.accountName, String())
        XCTAssertEqual(sut.btcAddressFormat, BtcAddressFormat.segwit.rawValue)
        XCTAssertNotNil(sut.test)
        XCTAssertEqual(sut.nameIsValid, false)
    }
    
    func testFormattedIndexStringReturnsCorrectStringForGivenIndex() throws {
        let formattedStringFor1Index = sut.formattedIndexString(1)
        XCTAssertEqual(formattedStringFor1Index, "1st word")
        
        let formattedStringFor2Index = sut.formattedIndexString(2)
        XCTAssertEqual(formattedStringFor2Index, "2nd word")
        
        let formattedStringFor3Index = sut.formattedIndexString(3)
        XCTAssertEqual(formattedStringFor3Index, "3rd word")
        
        let formattedStringFor21Index = sut.formattedIndexString(21)
        XCTAssertEqual(formattedStringFor21Index, "21st word")
        
        let formattedStringFor22Index = sut.formattedIndexString(22)
        XCTAssertEqual(formattedStringFor22Index, "22nd word")
        
        let formattedStringFor23Index = sut.formattedIndexString(23)
        XCTAssertEqual(formattedStringFor23Index, "23rd word")
        
        let formattedStringFor7Index = sut.formattedIndexString(7)
        XCTAssertEqual(formattedStringFor7Index, "7th word")
    }
    
    func testWalletNameIsValid() throws {
        XCTAssertEqual(sut.nameIsValid, false)
        sut.accountName = String()
        XCTAssertEqual(sut.nameIsValid, false)
        sut.accountName = "Name"
        XCTAssertEqual(sut.nameIsValid, true)
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
    
    func testMnemonicAccountType() throws {
        let accountType = CreateAccountViewModel.mnemonicAccountType()
        
        switch accountType {
        case .mnemonic(let words, let salt):
            XCTAssertEqual(words.count, 24)
            XCTAssertEqual(salt, "salty_password")
        }
    }
    
    func testCopyToClipboard() throws {
        let seedString = sut.test.seed.reduce(String(), { $0 + " " + $1 })
        
        sut.copyToClipboard()
        
        #if os(iOS)
        XCTAssertEqual(UIPasteboard.general.string, seedString)
        #else
        let testString = NSPasteboard.general.string(forType: .string)
        XCTAssertNotNil(testString, "pastboard test is empty")
        XCTAssertEqual(testString, seedString)
        #endif
    }
}
