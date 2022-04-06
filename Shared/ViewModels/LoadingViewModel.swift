//
//  LoadingViewModel.swift
//  Portal
//
//  Created by farid on 4/5/22.
//

import Foundation
import Combine

class LoadingViewModel: ObservableObject {
    @Published var passcode = String()
    @Published var isLocked = false
    @Published var wrongPasscode = false
    
    private var subscriptions = Set<AnyCancellable>()
    private let manager: IPasscodeManager
    
    init(passcodeManager: IPasscodeManager) {
        self.manager = passcodeManager
        
        passcodeManager.isLocked.sink { isLocked in
            self.isLocked = isLocked
            self.passcode = String()
        }
        .store(in: &subscriptions)
                
        $isLocked.sink { locked in
            if !locked {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Portal.shared.state.loading = false
                }
            }
        }
        .store(in: &subscriptions)
    }
    
    func tryUnlock() {
        if manager.passcode == passcode {
            isLocked.toggle()
        } else {
            passcode = String()
            wrongPasscode.toggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.wrongPasscode.toggle()
            }
        }
    }
}

extension LoadingViewModel {
    static func config() -> LoadingViewModel {
        let passcodeManager = Portal.shared.passcodeManager
        
        return LoadingViewModel(passcodeManager: passcodeManager)
    }
}
