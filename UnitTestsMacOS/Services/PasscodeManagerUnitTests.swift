//
//  PasscodeManagerUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 4/6/22.
//

import XCTest
@testable import Portal

import Combine
import KeychainAccess

class PasscodeManagerUnitTests: XCTestCase {
    
    private var sut: PasscodeManager!
    private let keychain = Keychain(service: "UnitTestsKeychainService")
    private var subsriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storage = KeychainStorage(keychain: keychain)
        sut = PasscodeManager(storage: storage)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    func testPasscode() throws {
        let testCode = "passcode"
        sut.store(passcode: testCode)
        XCTAssertEqual(sut.passcode, testCode)
    }
    
    func testLock() throws {
        sut.lock()

        sut.isLocked.sink { locked in
            XCTAssertEqual(locked, true)
        }
        .store(in: &subsriptions)
    }
    
    func testStorePasscode() throws {
        let passcode = "test-code"
        XCTAssertNotEqual(passcode, sut.passcode)
        sut.store(passcode: passcode)
        XCTAssertEqual(passcode, sut.passcode)
    }
}
