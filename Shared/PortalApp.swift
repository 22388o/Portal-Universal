//
//  PortalApp.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

@main
struct PortalApp: App {
    private let notificationCenter = NotificationCenter.default
    private let willTerninateNotification = UIApplication.willTerminateNotification
    private let willEnterForegroundNotification = UIApplication.willEnterForegroundNotification
    private let didEnterBackgroundNotification = UIApplication.didEnterBackgroundNotification
    private let didBecomeActiveNotification = UIApplication.didBecomeActiveNotification
    
    init() {
        #if os(iOS)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.lightActiveLabel)], for: .normal)
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(Portal.shared.marketDataProvider)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .edgesIgnoringSafeArea(.all)
                .onReceive(notificationCenter.publisher(for: willTerninateNotification), perform: { _ in
                    Portal.shared.onTerminate()
                })
                .onReceive(notificationCenter.publisher(for: didEnterBackgroundNotification), perform: { _ in
                    Portal.shared.didEnterBackground()
                })
                .onReceive(notificationCenter.publisher(for: didBecomeActiveNotification), perform: { _ in
                    Portal.shared.didBecomeActive()
                })
        }
    }
}
