//
//  NotificationsView.swift
//  Portal
//
//  Created by Farid on 22.07.2021.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject private var service = Portal.shared.notificationService
        
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
                        LazyVStack_(spacing: 0) {
                            ForEach(service.notifications, id: \.id) { notification in
                                NotificationView(notification: notification)
                                Divider()
                            }
                        }
                    }
                }
                
                Spacer()
                
                PButton(label: "Close", width: 80, height: 30, fontSize: 12, enabled: true) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        Portal.shared.state.modalView = .allNotifications
                    }
                }
                .shadow(color: Color.pButtonShadowColor.opacity(0.1), radius: 6, x: 0, y: 4)
                .padding()
            }
        }
        .frame(width: 288, height: 250)
        .transition(.move(edge: .leading))
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
