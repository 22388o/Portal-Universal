//
//  MockedReachabilityService.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/20/22.
//

import Foundation
import Combine

@testable import Portal

struct MockedReachabilityService: IReachabilityService {
    var isReachable = CurrentValueSubject<Bool, Never>(true)
    
    func startMonitoring() {
        
    }
    
    func stopMonitoring() {
        
    }
}
