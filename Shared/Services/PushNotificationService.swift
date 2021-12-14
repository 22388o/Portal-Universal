//
//  PushNotificationService.swift
//  Portal
//
//  Created by farid on 12/6/21.
//

#if os(macOS)
import Cocoa
#endif
import UserNotifications

final class PushNotificationService: NSObject {
    private let updater: PushTokenUpdater
    private let appId: String
    
    init(appId: String) {
        self.appId = appId
        self.updater = PushTokenUpdater()
    }
    
    func registerForRemoteNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                print("Push notifications permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
            }
    }
    
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
#if os(macOS)
                NSApplication.shared.registerForRemoteNotifications()
#endif
            }
        }
    }
    
    func registerPushNotificationToken(_ token: String) {
        print("Push notification Device Token: \(token)")
        updater.update(devId: appId, token: token)
    }
    
}

#if os(macOS)
extension PushNotificationService: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool { true }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        print("did deliver notification")
    }
}
#endif
