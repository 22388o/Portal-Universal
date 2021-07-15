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
        
    init() {
        if let url = Bundle.main.url(forResource: "alert", withExtension: "mp3") {
            player = AVPlayer.init(url: url)
        } else {
            player = nil
        }
    }
    
    func add(_ notification: PNotification) {
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

import SwiftUI

struct NotificationView: View {
    let notification: PNotification
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "plus.circle")
            VStack(alignment: .leading) {
                Text(notification.message)
                    .foregroundColor(Color.lightActiveLabel)
                Text(notification.date.timeAgoSinceDate(shortFormat: true))
                    .foregroundColor(Color.lightInactiveLabel)
            }
            .font(.mainFont(size: 12))
            Spacer()
        }
        .padding()
    }
}

struct AlertView_Previews: PreviewProvider {
    static let notification = PNotification(message: "test warning message")
    static var previews: some View {
        NotificationView(notification: notification)
    }
}

struct NotificationsView: View {
    @Binding var presented: Bool
    
    @ObservedObject private var service = Portal.shared.notificationService
    
    init(presented: Binding<Bool>) {
        self._presented = presented
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 2)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Notifications and alerts")
                        .font(.mainFont(size: 12, bold: true))
                        .foregroundColor(Color.walletsLabel)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 9)
                    Spacer()
                }
                
                Divider()
                
                Spacer()
                
                if service.notifications.isEmpty {
                    Text("There is no notifications yet.")
                        .font(.mainFont(size: 10, bold: true))
                        .foregroundColor(Color.lightActiveLabel)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(service.notifications, id: \.id) { notification in
                                NotificationView(notification: notification)
                                Divider()
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .frame(width: 288, height: 250)
        .transition(.move(edge: .leading))
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(presented: .constant(true))
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
