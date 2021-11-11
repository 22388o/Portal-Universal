//
//  PortalApp.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

@main
struct PortalApp: App {
    
    @UIApplicationDelegateAdaptor(PortalAppDelegate.self) private var appDelegate

    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.lightActiveLabel)], for: .normal)
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
