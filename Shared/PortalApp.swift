//
//  PortalApp.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

@main
struct PortalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
