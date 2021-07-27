//
//  NotificationService.swift
//  Portal
//
//  Created by Farid on 28.06.2021.
//

import Foundation
import AVFoundation

final class NotificationService: ObservableObject {

    private let player: AVPlayer?
    
    @Published private(set) var notifications: [PNotification] = []
    @Published private(set) var newAlerts: Int = 0
    @Published private(set) var alertsBeenSeen: Bool = false
        
    init(adapterManager: IAdapterManager) {
        if let url = Bundle.main.url(forResource: "alert", withExtension: "mp3") {
            player = AVPlayer.init(url: url)
        } else {
            player = nil
        }
    }
    
    func notify(_ notification: PNotification) {
        player?.seek(to: .zero)
        player?.play()
        
        DispatchQueue.main.async {
            self.newAlerts += 1
            self.alertsBeenSeen = false
            self.notifications.append(notification)
        }
    }
    
    func markAllAlertsViewed() {
        alertsBeenSeen.toggle()
        newAlerts = 0
    }
    
    func clear() {
        notifications = []
    }
}

struct PNotification: Hashable {
    let id = UUID()
    let date = Date()
    let message: String
}
