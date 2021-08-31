//
//  AppDelegate.swift
//  Portal (macOS)
//
//  Created by Farid on 23.08.2021.
//

import SwiftUI

#if os(macOS)
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = RootView()
            .environmentObject(Portal.shared.marketDataProvider)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        
        window?.title = "Portal"
        window?.isReleasedWhenClosed = false
        window?.center()
        window?.setFrameAutosaveName("Main Window")
        window?.contentView = NSHostingView(rootView: contentView)
        window?.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.window = NSApp.mainWindow
    }
}
#endif
