//
//  PasscodeSetttingsViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 4/6/22.
//

import XCTest
@testable import Portal
import Combine
import KeychainAccess

class PasscodeSetttingsViewModelUnitTests: XCTestCase {
    private let state = PortalState()
    private let keychain = Keychain(service: "UnitTestsKeychainService")
    private var sut: PasscodeSetttingsViewModel!
    private var passcodeManager: IPasscodeManager!
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storage = KeychainStorage(keychain: keychain)
        try storage.clear()
        
        passcodeManager = PasscodeManager(storage: storage)
        
        sut = PasscodeSetttingsViewModel.init(state: state, passcodeManager: passcodeManager)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        passcodeManager = nil
    }

    func testResetPasscode() {
        sut.confirmedPasscode = "ConfirmedPasscode"
        
        sut.resetPasscode()
        
        XCTAssertEqual(sut.confirmedPasscode, String())
        XCTAssertEqual(sut.hasPasscode, false)
    }
    
    func testSetPasscode() {
        XCTAssertEqual(sut.hasPasscode, false)
        sut.passcode = "test-code"
        sut.setPasscode()
        XCTAssertEqual(sut.hasPasscode, true)
    }
    
    func testLock() {
        sut.lock()
        
        XCTAssertEqual(state.modalView, .none)
        XCTAssertEqual(state.loading, true)
        
        passcodeManager.isLocked.sink { locked in
            XCTAssertEqual(locked, true)
        }
        .store(in: &subscriptions)
    }
    
    func testConfig() throws {
        sut = PasscodeSetttingsViewModel.config()
        XCTAssertNotNil(sut)
    }
    
    func testHasPasscode() throws {
        XCTAssertFalse(sut.hasPasscode)
        sut.passcode = "test-code"
        sut.setPasscode()
        XCTAssertTrue(sut.hasPasscode)
    }
    
    func testSetPasscodeButtonEnabled() throws {
        XCTAssertFalse(sut.setPasscodeButtonEnabled)
        let testCode = "test-code"
        sut.passcode = testCode
        sut.confirmedPasscode = testCode
        XCTAssertTrue(sut.setPasscodeButtonEnabled)
    }
        
    func testChangePasscodeButtonEnabled() throws {
        XCTAssertFalse(sut.changePasscodeButtonEnabled)
        let testCode = "test-code"
        sut.passcode = testCode
        sut.setPasscode()
        sut.confirmedPasscode = testCode
        XCTAssertTrue(sut.changePasscodeButtonEnabled)
    }
    
    func testProtectWithPasscodeToggleEnabled() throws {
        let testCode = "test-code"
        sut.protectedWithPasscode = true
        sut.passcode = testCode
        sut.setPasscode()
        sut.confirmedPasscode = String(testCode.dropFirst())
        XCTAssertFalse(sut.protectWithPasscodeToggleEnabled)
        sut.confirmedPasscode = testCode
        XCTAssertTrue(sut.protectWithPasscodeToggleEnabled)
        sut.protectedWithPasscode = false
        XCTAssertTrue(sut.protectWithPasscodeToggleEnabled)
    }
    
    func testLockButtonEnabled() throws {
        XCTAssertFalse(sut.lockButtonEnabled)
        sut.passcode = "test-code"
        sut.setPasscode()
        sut.protectedWithPasscode = true
        XCTAssertTrue(sut.lockButtonEnabled)
    }
}
