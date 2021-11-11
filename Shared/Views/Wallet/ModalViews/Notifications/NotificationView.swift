//
//  NotificationView.swift
//  Portal
//
//  Created by Farid on 22.07.2021.
//

import SwiftUI

struct NotificationView: View {
    let notification: PNotification
    
    var body: some View {
        HStack(alignment: .top) {
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

struct NotificationView_Previews: PreviewProvider {
    static let notification = PNotification(message: "test warning message")
    static var previews: some View {
        NotificationView(notification: notification)
    }
}
