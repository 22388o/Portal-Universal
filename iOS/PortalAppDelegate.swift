//
//  PortalAppDelegate.swift
//  Portal (iOS)
//
//  Created by Manoj Duggirala on 10/21/21.
//

import UIKit
import Mixpanel
import Bugsnag

class PortalAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
        // need to implement registering with server api
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
}

import SwiftUI

class LocalNotification: ObservableObject {
    init() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (allowed, error) in
            //This callback does not trigger on main loop be careful
//            if allowed {
//                os_log(.debug, "Allowed")
//            } else {
//                os_log(.debug, "Error")
//            }
        }
    }
    
    func setLocalNotification(title: String, subtitle: String, body: String, when: Double) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: when, repeats: false)
        let request = UNNotificationRequest.init(identifier: "localNotificatoin", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
}

//struct LocalNotificationDemoView: View {
//    @StateObject var localNotification = LocalNotification()
//    @ObservedObject var notificationCenter: NotificationCenter
//    var body: some View {
//        VStack {
//            Button("schedule Notification") {
//                localNotification.setLocalNotification(title: "title",
//                                                       subtitle: "Subtitle",
//                                                       body: "this is body",
//                                                       when: 10)
//            }
//
//            if let dumbData = notificationCenter.dumbData  {
//                Text("Old Notification Payload:")
//                Text(dumbData.actionIdentifier)
//                Text(dumbData.notification.request.content.body)
//                Text(dumbData.notification.request.content.title)
//                Text(dumbData.notification.request.content.subtitle)
//            }
//        }
//    }
//}

extension UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications!")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
}
