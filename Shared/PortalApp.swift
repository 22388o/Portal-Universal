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
        
        //TODO: - Replace with IlocalStorage
        
        let defaults = UserDefaults.standard
        
        if defaults.integer(forKey: "AppLaunchesCounts") == 0 {
            walletsService.clear()
            defaults.setValue(1, forKey: "AppLaunchesCounts")
        } else {
            let counter = defaults.integer(forKey: "AppLaunchesCounts")
            defaults.setValue(counter + 1, forKey: "AppLaunchesCounts")
        }
        
        //
        
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
