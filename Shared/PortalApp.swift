//
//  PortalApp.swift
//  Shared
//
//  Created by Farid on 22.03.2021.
//

import SwiftUI

@main
struct PortalApp: App {
    private let walletsService: WalletsService
    
    init() {
        walletsService = WalletsService(context: PersistenceController.shared.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            RootView(walletService: walletsService)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
