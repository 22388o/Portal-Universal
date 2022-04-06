//
//  PasscodeManager.swift
//  Portal
//
//  Created by farid on 4/5/22.
//

import Combine

protocol IPasscodeManager {
    var isLocked: CurrentValueSubject<Bool, Never> { get }
    var passcode: String? { get }
    func store(passcode: String?)
    func lock()
}

class PasscodeManager: IPasscodeManager {
    static let passcodeIDKey = "PASSCODE_ID"
    
    let storage: IKeychainStorage
    
    var isLocked: CurrentValueSubject<Bool, Never>
    
    var passcode: String? {
        storage.value(for: Self.passcodeIDKey)
    }
    
    init(storage: IKeychainStorage) {
        self.storage = storage
        let locked = storage.value(for: Self.passcodeIDKey) != nil
        self.isLocked = CurrentValueSubject<Bool, Never>(locked)
    }
    
    func store(passcode: String?) {
        try? storage.set(value: passcode, for: Self.passcodeIDKey)
    }
    
    func lock() {
        isLocked.send(true)
    }
}
