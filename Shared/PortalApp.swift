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
        MarketDataRepository.service.start()
        
        #if os(iOS)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.lightActiveLabel)], for: .normal)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(walletsService)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
