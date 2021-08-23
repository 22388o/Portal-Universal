//
//  PortalApp.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

#if os(iOS)
@main
struct PortalApp: App {

    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.lightActiveLabel)], for: .normal)
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(Portal.shared.marketDataProvider)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
#endif
