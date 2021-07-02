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
    private let marketDataRepository: MarketDataRepository
    
    init() {
        walletsService = WalletsService(context: PersistenceController.shared.container.viewContext)
        marketDataRepository = MarketDataRepository()
        
        #if os(iOS)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.lightActiveLabel)], for: .normal)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(walletsService)
                .environmentObject(marketDataRepository)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
