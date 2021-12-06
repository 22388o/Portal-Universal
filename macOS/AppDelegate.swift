//
//  AppDelegate.swift
//  Portal (macOS)
//
//  Created by Farid on 23.08.2021.
//

import SwiftUI
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = RootView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 935, height: 768),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        
        window?.title = "Portal"
        window?.isReleasedWhenClosed = true
        window?.center()
        window?.setFrameAutosaveName("Main Window")
        window?.contentView = NSHostingView(rootView: contentView)
        window?.makeKeyAndOrderFront(nil)
        
        NSApp.appearance = NSAppearance(named: .aqua)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.window = NSApp.mainWindow
    }
}

//MARK: - Remote notifications
extension AppDelegate {
    // Handle remote notification registration.
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Forward the token to your provider, using a custom method.
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Portal.shared.pushNotificationService.registerPushNotificationToken(token)
    }

    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }

    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        handleRemoteNotification(userInfo)
    }

    private func handleRemoteNotification(_ userInfo: [String : Any]) {
        guard let aps = userInfo["aps"] as? [String : Any], let alertMessage = aps["alert"] as? String else {
            print(userInfo)
            return
        }
    }
}
