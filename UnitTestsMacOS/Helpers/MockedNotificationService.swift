//
//  MockedNotificationService.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/20/22.
//

import Foundation
import Combine
@testable import Portal

class MockedNotificationService: INotificationService {
    var notifications = CurrentValueSubject<[PNotification], Never>([])
    
    var newAlerts = CurrentValueSubject<Int, Never>(1)
    
    var alertsBeenSeen = CurrentValueSubject<Bool, Never>(false)
    
    func notify(_ notification: PNotification) {
        
    }
    
    func markAllAlertsViewed() {
        alertsBeenSeen.value.toggle()
        newAlerts.value = 0
    }
    
    func clear() {
        
    }
}
