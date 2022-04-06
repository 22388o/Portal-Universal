//
//  PasscodeSettingsViewModel.swift
//  Portal
//
//  Created by farid on 4/4/22.
//

import Foundation
import Combine

class PasscodeSetttingsViewModel: ObservableObject {
    @Published var passcode = String()
    @Published var confirmedPasscode = String()
    @Published var changePasscode = false
    @Published var protectedWithPasscode = false
    
    var hasPasscode: Bool {
        passcodeManager.passcode != nil
    }
    
    var setPasscodeButtonEnabled: Bool {
        !passcode.isEmpty && !confirmedPasscode.isEmpty && passcode == confirmedPasscode
    }
    
    var changePasscodeButtonEnabled: Bool {
        passcodeManager.passcode == confirmedPasscode
    }
    
    var protectWithPasscodeToggleEnabled: Bool {
        protectedWithPasscode ? changePasscodeButtonEnabled : true
    }
    
    var lockButtonEnabled: Bool {
        hasPasscode && protectedWithPasscode
    }
    
    private let passcodeManager: IPasscodeManager
    private let state: PortalState
    
    private var subscriptions = Set<AnyCancellable>()
        
    init(state: PortalState, passcodeManager: IPasscodeManager) {
        self.state = state
        self.passcodeManager = passcodeManager
        
        protectedWithPasscode = passcodeManager.passcode != nil
                
        $protectedWithPasscode.sink { protected in
            if !protected {
                passcodeManager.store(passcode: nil)
            }
        }
        .store(in: &subscriptions)
    }
    
    func resetPasscode() {
        confirmedPasscode = String()
        passcodeManager.store(passcode: nil)
    }
    
    func setPasscode() {
        passcodeManager.store(passcode: passcode)
    }
    
    func lock() {
        passcodeManager.lock()
        
        state.modalView = .none
        state.loading = true
    }
}

extension PasscodeSetttingsViewModel {
    static func config() -> PasscodeSetttingsViewModel {
        let passcodeManager = Portal.shared.passcodeManager
        let state = Portal.shared.state
        
        return PasscodeSetttingsViewModel(state: state, passcodeManager: passcodeManager)
    }
}
