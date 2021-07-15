//
//  PortalApp.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

@main
struct PortalApp: App {
    init() {
        #if os(iOS)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.lightActiveLabel)], for: .normal)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(Portal.shared.marketDataProvider)
                .environmentObject(Portal.shared.walletsService)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
